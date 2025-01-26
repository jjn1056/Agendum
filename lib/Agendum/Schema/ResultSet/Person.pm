package Agendum::Schema::ResultSet::Person;

use Agendum::Syntax;
use base 'Agendum::Schema::ResultSet';

sub unauthenticated_user($self, $args=+{}) {
  return $self->new_result($args);  
}

1;