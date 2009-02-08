package App::TermStyle::Script::Command::load;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run (HashRef $options, ArrayRef $args) {

    die "Missing the style name argument specifying the name of the stored profile.\n"
        unless @$args >= 1;

    die "Too many arguments; Only expected the profile name.\n"
        if @$args > 1;

    my $name = $args->[0];

    die "Unknown profile: '$name'\n"
        unless $self->has_profile($name);

    my $profile = $self->get_profile($name);
    my $current = $self->window->create_profile('LAST');

    $self->set_profile(LAST => $current);
    $self->window->load_profile($profile);

    $self->flush_config;

    say "loaded profile '$name'";
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::load - load a stored profile by name

=cut
