package Agendum::Schema::Result::Label;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("labels");

__PACKAGE__->add_columns(
  label_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  name => { data_type => 'varchar', is_nullable => 0, size => 100 },
  created_at => { data_type => 'timestamp', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamp', is_nullable => 1, default_value => \'NOW()' },
);

__PACKAGE__->set_primary_key("label_id");

__PACKAGE__->has_many(
  task_labels =>
  'Agendum::Schema::Result::TaskLabel',
  { 'foreign.label_id' => 'self.label_id' }
);

__PACKAGE__->many_to_many(
  tasks => 'task_labels', 'task'
);

1;