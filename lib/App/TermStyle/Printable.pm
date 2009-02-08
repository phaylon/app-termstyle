package App::TermStyle::Printable;
use Moose::Role;
use MooseX::Method::Signatures;

use namespace::clean -except => 'meta';

requires qw( printable_properties );

1;
