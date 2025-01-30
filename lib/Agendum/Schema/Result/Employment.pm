package Agendum::Schema::Result::Employment;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("employment");

__PACKAGE__->add_columns(
  employment_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  label => { data_type => 'varchar', is_nullable => 0, size => '24' },
);

__PACKAGE__->set_primary_key("employment_id");
__PACKAGE__->add_unique_constraint(['label']);

__PACKAGE__->has_many(
  profile =>
  'Agendum::Schema::Result::Profile',
  { 'foreign.employment_id' => 'self.employment_id' }
);

1;
