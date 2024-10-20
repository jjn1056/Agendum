package Agendum::Schema::Result;

use base 'DBIx::Class';
use Agendum::Syntax;

# For the dependency tracker
use DBIx::Class::InflateColumn::DateTime;
use DBIx::Class::ResultClass::TrackColumns;
use DBIx::Class::BcryptColumn;
use DBIx::Class::InflateColumn::DateTime;


__PACKAGE__->load_components(qw/
  Valiant::Result
  BcryptColumn
  ResultClass::TrackColumns
  Core
  InflateColumn::DateTime
  /);

1;
