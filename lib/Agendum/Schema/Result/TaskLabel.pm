package Agendum::Schema::Result::TaskLabel;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("task_labels");

__PACKAGE__->add_columns(
  task_id => { data_type => 'integer', is_nullable => 0 },
  label_id => { data_type => 'integer', is_nullable => 0 },
);

__PACKAGE__->set_primary_key("task_id", "label_id");

__PACKAGE__->belongs_to(
  task =>
  'Agendum::Schema::Result::Task',
  { 'foreign.task_id' => 'self.task_id' }
);

__PACKAGE__->belongs_to(
  label =>
  'Agendum::Schema::Result::Label',
  { 'foreign.label_id' => 'self.label_id' }
);

1;