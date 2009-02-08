package App::TermStyle::Script::Command::list;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run {

    my @profiles =
        sort { $a->name cmp $b->name }
        grep { $_->name ne 'LAST' }
            $self->profiles;

    for my $profile (@profiles) {
        say sprintf "profile '%s'", $profile->name;
        $self->output_object_table($profile);
        say '';
    }
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::list - output all stored profiles

=cut
