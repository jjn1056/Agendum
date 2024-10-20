package Agendum::Schema::ResultSet;

use base 'DBIx::Class::ResultSet';
use Agendum::Syntax;

use Valiant; # For the dependency tracker

__PACKAGE__->load_components(qw/
  Valiant::ResultSet
  Helper::ResultSet::Shortcut
  Helper::ResultSet::Me
  Helper::ResultSet::SetOperations
  Helper::ResultSet::IgnoreWantarray
/);

sub to_array($self) {
  return $self->search(
    {},
    {result_class => 'DBIx::Class::ResultClass::HashRefInflator'}
  )->all;
}

1;
