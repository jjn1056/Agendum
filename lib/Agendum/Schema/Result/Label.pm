package Agendum::Schema::Result::Label;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("labels");

__PACKAGE__->add_columns(
  label_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  name => { data_type => 'varchar', is_nullable => 0, size => 100 },
);

__PACKAGE__->set_primary_key("label_id");
__PACKAGE__->add_unique_constraint(['name']);

__PACKAGE__->has_many(
  task_labels =>
  'Agendum::Schema::Result::TaskLabel',
  { 'foreign.label_id' => 'self.label_id' }
);

1;
