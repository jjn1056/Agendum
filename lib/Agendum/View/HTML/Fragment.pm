package Agendum::View::HTML::Fragment;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

__PACKAGE__->meta->make_immutable;
__DATA__
%= $content
