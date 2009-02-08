package App::TermStyle::Window;
use 5.010;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose    qw( Int Object );
use MooseX::Method::Signatures;

use aliased 'App::TermStyle::Window::Information';
use aliased 'App::TermStyle::Window::Profile';

#use Data::Dump          qw( pp );
use IPC::System::Simple qw( capturex runx );

use namespace::clean -except => 'meta';

has window_id => (
    is          => 'ro',
    isa         => Int,
    required    => 1,
    builder     => 'find_window_id',
);

has information => (
    is          => 'ro',
    isa         => subtype(Object, sub { $_->isa(Information) }),
    required    => 1,
    builder     => '_build_information',
    lazy        => 1,
    handles     => [qw( properties ), Information->properties],
);

method create_profile (Str $name) {

    return Profile->new(
        name => $name,
        map  {( $_ => $self->information->$_ )}
        grep { $self->information->can($_) }
        grep { $_ ne 'name' }
        grep { defined }
        map  { $_->reader // $_->accessor }
            Profile->meta->compute_all_applicable_attributes,
    );
}

method load_profile (Object $profile) {

    runx('wmctrl', 
        '-r' => ':ACTIVE:', 
        '-e' => join(',', 
            0,
            $profile->position_x,
            $profile->position_y,
            $profile->width,
            $profile->height,
        ),
    );
}

method find_window_id {
    
    my $xprop = capturex('xprop', -root, '_NET_ACTIVE_WINDOW');
    chomp $xprop;

    if ($xprop =~ /^_NET_ACTIVE_WINDOW\(.*?\):\s+window\s+id\s+#\s+(0x.+)\s*$/) {
        return hex $1;
    }
    else {
        die "Unable to parse xprop output: $xprop\n";
    }
}

method _build_information {
    return Information->new(window_id => $self->window_id);
}

1;
