package App::TermStyle::Window::Information;
use 5.010;
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose    qw( Int HashRef Str ArrayRef );
use MooseX::ClassAttribute;
use MooseX::Method::Signatures;

use IPC::System::Simple     qw( capturex );
#use Data::Dump              qw( pp );

use namespace::clean -except => 'meta';

has window_id => (
    is          => 'ro',
    isa         => Int,
    required    => 1,
);

has _window_data => (
    is          => 'ro',
    isa         => HashRef[Str],
    required    => 1,
    lazy        => 1,
    init_arg    => undef,
    builder     => '_fetch_window_data',
);

my $PixelRegex      = qr/[+-]\d+/;
my $PositionRegex   = qr/($PixelRegex)($PixelRegex)/,

my $PositionType    = subtype ArrayRef[Int], where { @$_ == 2 };
my $CornersType     = subtype ArrayRef[$PositionType], where { @$_ == 4 };
my $CornersStrType  = subtype Str, where { 
    /^
        $PositionRegex
        \s+
        $PositionRegex
        \s+
        $PositionRegex
        \s+
        $PositionRegex
    $/x
};

coerce $CornersType, from $CornersStrType, via { 
    my @corners = split /\s+/, $_;
    [ map { /^$PositionRegex$/; [0+$1, 0+$2] } @corners ];
};

my $XWinInfoRegex = qr/^\s*window\s+id:\s+0x\S+?\s+"(.+)"\s*$/i;
my $XWinInfoType  = subtype Str, where { /$XWinInfoRegex/ };
my $TitleType     = subtype Str, where { 1 };

coerce $TitleType, from $XWinInfoType, via { /$XWinInfoRegex/ and $1 };

my @build_fields = (
    [position_x     => [Int, 'absolute_upper_left_x']],
    [position_y     => [Int, 'absolute_upper_left_y']],
    [width          => [Int, 'width']],
    [height         => [Int, 'height']],
    [depth          => [Int, 'depth']],
    [title          => [$TitleType, 'xwininfo', coerce => 1]],
    [window_class   => [Str, 'class']],
    [visual_class   => [Str, 'visual_class']],
    [corners        => [$CornersType, 'corners', coerce => 1]],
    [map_state      => [Str, 'map_state']],
    [xwininfo       => [Str, 'xwininfo']],
);
my @field_names = map { $_->[0] } @build_fields;

for my $attr (@build_fields) {
    my ($field, $info) = @$attr;
    my ($type, $hashkey, %properties) = @$info;

    has $field => (
        is          => 'ro',
        isa         => $type,
        required    => 0,
        lazy        => 1,
        init_arg    => undef,
        ( $properties{builder}
          ? ()
          : (default => (sub { my $k = shift; sub { (shift)->_window_data->{ $k } } })->($hashkey))
        ),
        %properties,
    );
}

my @corner_properties = qw(
    top_left_corner
    top_right_corner
    bottom_right_corner
    bottom_left_cornere
);

for my $corner_index (0 .. $#corner_properties) {
    my $prop = $corner_properties[ $corner_index ];

    has $prop => (
        is          => 'ro',
        isa         => $PositionType,
        required    => 1,
        lazy        => 1,
        init_arg    => undef,
        default     => (sub { my $i = shift; sub { (shift)->corners->[ $i ] } })->($corner_index),
    );
}

method properties { @field_names }

method printable_properties { 'window_id', $self->properties }

method _fetch_window_data {

    my @lines = capturex('xwininfo', -id => $self->window_id);
    chomp @lines;
    @lines = 
        map { s/^\s+//; $_ } 
        grep /:/,
        grep length, @lines;

    my %data = 
        map { my $n = $_->[0]; $n =~ s/[^a-z]+/_/ig; (lc($n), $_->[1]) }
        map { [ split /:\s*/, $_, 2 ] } @lines;

    return \%data;
};

with 'App::TermStyle::Printable';

1;
