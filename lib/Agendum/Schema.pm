package Agendum::Schema;

use base 'DBIx::Class::Schema';

use Agendum::Syntax;
use DBIx::Class::Helpers; # For the dependency tracker

__PACKAGE__->load_components(qw/
  Helper::Schema::QuoteNames
  Helper::Schema::DidYouMean
  Helper::Schema::DateTime/);

__PACKAGE__->load_namespaces(
  default_resultset_class => "DefaultRS");

1;
