package Agendum::Schema::Result::Profile;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("profile");

__PACKAGE__->add_columns(
  person_id => { data_type => 'integer', is_nullable => 0, is_foreign_key => 1 },
  state_id => { data_type => 'integer', is_nullable => 0, is_foreign_key => 1 },
  address => { data_type => 'varchar', is_nullable => 0, size => 48 },
  city => { data_type => 'varchar', is_nullable => 0, size => 32 },
  zip => { data_type => 'varchar', is_nullable => 0, size => 5 },
  birthday => { data_type => 'date', is_nullable => 1, datetime_undef_if_invalid => 1 },
  phone_number => { data_type => 'varchar', is_nullable => 1, size => 32 },
  employment_id => { data_type => 'integer', is_nullable => 0, foreign_key => 1 },
);

__PACKAGE__->set_primary_key("person_id");

__PACKAGE__->belongs_to(
  state =>
  'Agendum::Schema::Result::State',
  { 'foreign.state_id' => 'self.state_id' },
);

__PACKAGE__->belongs_to(
  person =>
  'Agendum::Schema::Result::Person',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->belongs_to(
  employment =>
  'Agendum::Schema::Result::Employment',
  { 'foreign.employment_id' => 'self.employment_id' },
);

__PACKAGE__->validates(address => (presence=>1, length=>[2,48]));
__PACKAGE__->validates(city => (presence=>1, length=>[2,32]));
__PACKAGE__->validates(zip => (presence=>1, format=>'zip'));
__PACKAGE__->validates(phone_number => (presence=>1, length=>[10,32]));
__PACKAGE__->validates(state_id => (presence=>1));
__PACKAGE__->validates(employment_id => (presence=>1));
__PACKAGE__->validates(birthday => (
    date => {
      max => sub { pop->now->subtract(days=>2) }, 
      min => sub { pop->years_ago(30) }, 
    }
  )
);

1;