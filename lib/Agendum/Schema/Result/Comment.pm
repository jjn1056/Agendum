package Agendum::Schema::Result::Comment;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("comments");

__PACKAGE__->add_columns(
  comment_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  task_id => { data_type => 'integer', is_nullable => 0 },
  content => { data_type => 'text', is_nullable => 0 },
  created_at => { data_type => 'timestamp', is_nullable => 1, default_value => \'NOW()' },
);

__PACKAGE__->set_primary_key("comment_id");

__PACKAGE__->belongs_to(
  task =>
  'Agendum::Schema::Result::Task',
  { 'foreign.task_id' => 'self.task_id' }
);

1;