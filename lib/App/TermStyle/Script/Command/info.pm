package App::TermStyle::Script::Command::info;
use 5.010;
use Moose;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

extends 'App::TermStyle::Script::Command';

method run {
    $self->output_object_table($self->window->information);
}

1;

__END__

=head1 NAME

App::TermStyle::Script::Command::info - output current window information

=cut
