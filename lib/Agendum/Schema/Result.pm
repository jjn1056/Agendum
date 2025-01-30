package Agendum::Schema::Result;

use base 'DBIx::Class';
use Agendum::Syntax;

# For the dependency tracker
use DBIx::Class::InflateColumn::DateTime;
use DBIx::Class::ResultClass::TrackColumns;
use DBIx::Class::BcryptColumn;
use DBIx::Class::InflateColumn::DateTime;
use DBIx::Class::Valiant::Result;
use DBIx::Class::Valiant::Result::HTML::FormFields;

__PACKAGE__->load_components(qw/
  Valiant::Result
  Valiant::Result::HTML::FormFields
  BcryptColumn
  ResultClass::TrackColumns
  Core
  InflateColumn::DateTime
  Helper::Row::SelfResultSet
/);

1;
