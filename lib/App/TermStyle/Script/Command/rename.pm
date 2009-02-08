package App::TermStyle::Script::Command::rename;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run (HashRef $options, ArrayRef $args) {

    die "Renaming a profile requires two arguments: The old and the new name.\n"
        unless @$args >= 2;

    die "Too many arguments; Only expected the old and the new profile name.\n"
        if @$args > 2;

    my ($old, $new) = @$args;

    die "Unknown profile: '$old'\n"
        unless $self->has_profile($old);

    my $profile = $self->remove_profile($old);
    $profile->name($new);
    $self->add_profile($profile);

    $self->flush_config;

    say "renamed profile '$old' to '$new'";
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::rename - rename a stored profile

=cut
