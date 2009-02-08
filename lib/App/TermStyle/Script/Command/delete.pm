package App::TermStyle::Script::Command::delete;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run (HashRef $options, ArrayRef $args) {

    die "Missing the style name argument specifying the name of the profile to delete.\n"
        unless @$args >= 1;

    die "Too many arguments; Only expected the profile name.\n"
        if @$args > 1;

    my $name = $args->[0];

    die "Unknown profile: '$name'\n"
        unless $self->has_profile($name);

    $self->remove_profile($name);
    $self->flush_config;

    say "Deleted stored profile '$name'";
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::delete - delete a profile from the storage

=cut
