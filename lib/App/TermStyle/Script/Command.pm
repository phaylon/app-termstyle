package App::TermStyle::Script::Command;
use 5.010;
use Moose;
use MooseX::AttributeHelpers;
use MooseX::Types::Moose        qw( Object HashRef Bool );
use MooseX::Types::Path::Class  qw( File );
use MooseX::Method::Signatures;

use aliased 'App::TermStyle::Window';
use aliased 'App::TermStyle::Window::Profile';

use JSON::Any;
use Carp                qw( croak );
#use Data::Dump          qw( pp );
use List::Util          qw( max );
use Path::Class::File;
use File::HomeDir;
use CLASS;

use namespace::clean -except => 'meta';

extends 'MooseX::App::Cmd::Command';

my $DefaultConfigFile = Path::Class::File->new('.app-termstyle-rc');
my $DefaultConfigPath = Path::Class::File->new(File::HomeDir->my_data, $DefaultConfigFile);

has config_path     => (
    is              => 'ro',
    isa             => File,
    required        => 1,
    lazy            => 1,
    coerce          => 1,
    builder         => '_build_default_config_path',
    documentation   => sprintf('path to the configuration file (default: %s)', $DefaultConfigPath),
    handles         => {
        'writable_config_handle'    => 'openw',
        'readable_config_handle'    => 'openr',
    },
);

has config => (
    traits         => [qw( NoGetopt )],
    is              => 'ro',
    isa             => HashRef,
    required        => 1,
    lazy            => 1,
    builder         => '_load_config',
);

has window => (
    traits          => [qw( NoGetopt )],
    is              => 'ro',
    isa             => Object,
    required        => 1,
    lazy            => 1,
    builder         => '_build_window',
);

has _json_transformer => (
    traits          => [qw( NoGetopt )],
    is              => 'ro',
    isa             => Object,
    required        => 1,
    lazy            => 1,
    builder         => '_build_json_transformer',
    handles         => [qw( to_json from_json )],
);

has _profiles => (
    metaclass       => 'Collection::Hash',
    traits          => [qw( NoGetopt )],
    is              => 'ro',
    isa             => HashRef[Object],
    required        => 1,
    lazy            => 1,
    builder         => '_load_profiles',
    provides        => {
        'set'           => 'set_profile',
        'get'           => 'get_profile',
        'exists'        => 'has_profile',
        'keys'          => 'profile_names',
        'values'        => 'profiles',
        'delete'        => 'remove_profile',
    },
);

has force => (
    is              => 'ro',
    isa             => Bool,
    documentation   => 'enforce operation (e.g. override)',
);

method flush_config {

    my $fh = $self->writable_config_handle
        or die sprintf "Unable to write to config file %s: $!\n", $self->config_path;

    my %profiles = map { ($_ => $self->get_profile($_)->to_hashref) } $self->profile_names;

    print $fh $self->to_json({
        profiles    => \%profiles,
        last_write  => time(),
    });

    return 1;
}

method add_profile (Object $profile) {

    my $name = $profile->name;

    die "There is already a profile named '$name'; Use --force to override.\n"
        if $self->has_profile($name) and not $self->force;

    $self->set_profile($name, $profile);
}

method _load_profiles {

    my $profiles = $self->config->{profiles} //= {};

    return +{
        map { ($_ => Profile->new(name => $_, %{ $profiles->{ $_ } // {} })) } 
            keys %$profiles
    };
}

method _load_config {

    return {}
        unless -e $self->config_path;

    return $self->from_json($self->config_path->slurp);
}

method _build_json_transformer {
    return JSON::Any->new;
}

method format_value (Str|ArrayRef $value, Int $maxlen) {

    return $value
        unless ref $value;

    return join "\n" . (' ' x ($maxlen + 2)), 
           map { $self->format_list_value($_) } 
           @$value
        if ref $value eq 'ARRAY';
}

method format_list_value (Str|ArrayRef $value) {

    return $value
        unless ref $value;

    return join ', ', @$value
        if ref $value eq 'ARRAY';
}

method output_object_table (Object $object) {

    my $printable = 'App::TermStyle::Printable';
    croak sprintf 'Object of class %s does not implement %s', ref($object), $printable
        unless $object->does($printable);

    my @data =
        map  { [$_ => $object->$_] }
            $object->printable_properties;

    return $self->output_table(\@data);
}

method output_table (ArrayRef $table_data) {

    my @names  = map { $_->[0] } @$table_data;
    my $maxlen = max(map { length } @names) + 3;

    for my $row (@$table_data) {
        my ($property, $value) = @$row;
        
        (my $name = $property) =~ s/_/ /g;
        say sprintf "%${maxlen}s: %s", $name, $self->format_value($value, $maxlen);
    }
}

method _build_default_config_path {
    return $DefaultConfigPath;
}

method _build_window {
    return Window->new;
}

1;
