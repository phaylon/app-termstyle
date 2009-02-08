package App::TermStyle::Window::Profile;
use Moose;
use MooseX::Types::Moose qw( Int Str );
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

has name => (
    is          => 'rw',
    isa         => Str,
    required    => 1,
);

has position_x => (
    is          => 'rw',
    isa         => Int,
    required    => 1,
);

has position_y => (
    is          => 'rw',
    isa         => Int,
    required    => 1,
);

has width => (
    is          => 'rw',
    isa         => Int,
    required    => 1,
);

has height => (
    is          => 'rw',
    isa         => Int,
    required    => 1,
);

method printable_properties { qw( position_x position_y width height ) }

method to_hashref {
    return +{ map { ($_ => $self->$_) } $self->printable_properties };
}

with 'App::TermStyle::Printable';

1;
