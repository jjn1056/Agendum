package Agendum::Schema::Result::Person;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("person");

__PACKAGE__->add_columns(
  person_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  public_id => { data_type => 'uuid', is_nullable => 0 },
  email => { data_type => 'text', is_nullable => 0 },
  given_name => { data_type => 'text', is_nullable => 0 },
  family_name => { data_type => 'text', is_nullable => 0 },
  created_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
);

__PACKAGE__->set_primary_key("person_id");
__PACKAGE__->add_unique_constraint(["public_id"]);
__PACKAGE__->add_unique_constraint(["email"]);

sub authenticated ($self) {
  return $self->in_storage;
}

1;