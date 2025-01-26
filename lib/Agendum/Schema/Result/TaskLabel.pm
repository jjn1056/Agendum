package Agendum::Schema::Result::TaskLabel;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("task_labels");

__PACKAGE__->add_columns(
  task_id => { data_type => 'integer', is_nullable => 0, is_foreign_key => 1 },
  person_id => { data_type => 'integer', is_nullable => 0, is_foreign_key => 1 },
  label_id => { data_type => 'integer', is_nullable => 0, is_foreign_key => 1 },
);

__PACKAGE__->set_primary_key("task_id", "person_id", "label_id");

__PACKAGE__->belongs_to(
  task =>
  'Agendum::Schema::Result::Task',
  { 'foreign.task_id' => 'self.task_id', 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->belongs_to(
  label =>
  'Agendum::Schema::Result::Label',
  { 'foreign.label_id' => 'self.label_id' }
);

__PACKAGE__->belongs_to(
  person =>
  'Agendum::Schema::Result::Person',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->accept_nested_for('label', {find_with_uniques=>1, allow_destroy=>1});

1;
