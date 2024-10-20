package Agendum::Schema::Result::Task;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("tasks");

__PACKAGE__->add_columns(
  task_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  title => { data_type => 'varchar', is_nullable => 0, size => 255 },
  description => { data_type => 'text', is_nullable => 1 },
  due_date => { data_type => 'date', is_nullable => 1 },
  priority => { data_type => 'integer', is_nullable => 1, default_value => 1 },
  status => { data_type => 'varchar', is_nullable => 1, size => 50, default_value => 'pending' },
  created_at => { data_type => 'timestamp', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamp', is_nullable => 1, default_value => \'NOW()' },
);

__PACKAGE__->set_primary_key("task_id");

__PACKAGE__->has_many(
  comments =>
  'Agendum::Schema::Result::Comment',
  { 'foreign.task_id' => 'self.task_id' }
);

__PACKAGE__->has_many(
  task_labels => 'Agendum::Schema::Result::TaskLabel',
  { 'foreign.task_id' => 'self.task_id' }
);


1;
