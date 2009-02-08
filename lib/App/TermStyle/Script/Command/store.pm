package App::TermStyle::Script::Command::store;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use List::MoreUtils qw( any );

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run (HashRef $options, ArrayRef $args) {

    die "Missing the style name argument specifying the name of the new profile.\n"
        unless @$args >= 1;

    die "Too many arguments; Only expected the profile name.\n"
        if @$args > 1;

    die "Illegal profile name: '$args->[0]'; The name is reserved for internal purposes.\n"
        if any { $_ eq $args->[0] } qw( LAST );

    my $profile = $self->window->create_profile($args->[0]);
    $self->add_profile($profile);
    $self->flush_config;

    say sprintf "profile '%s' created from window '%s'", $profile->name, $self->window->title;
    $self->output_object_table($profile);
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::store - store the current settings as a new style

=cut
