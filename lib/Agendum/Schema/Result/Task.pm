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
  created_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
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

__PACKAGE__->accept_nested_for('task_labels', {allow_destroy=>1});
__PACKAGE__->accept_nested_for('comments', {allow_destroy=>1});

__PACKAGE__->validates(title => (presence=>1, length=>[2,48]));
__PACKAGE__->validates(description => (presence=>1, length=>[2,2000]));

__PACKAGE__->validates(priority => (presence=>1));
__PACKAGE__->validates(status => (presence=>1));

__PACKAGE__->validates(status => (
    presence => 1,
    inclusion => \&status_list,
    with => {
      method => 'valid_status',
      on => 'update',
      if => 'is_column_changed', # This method defined by DBIx::Class::Row
    },
  )
);

__PACKAGE__->validates(due_date => (
    presence => 1,
    date => {
      min => sub { pop->now->truncate( to => 'day' )->subtract(seconds => 1) },
      if => 'is_column_changed',
    }
  )
);

sub status_list {
  return qw(pending in_progress on_hold blocked canceled completed);
}

sub valid_status($self, $attribute_name, $value, $opt) {
  my $old = $self->get_column_storage($attribute_name);

  if($value eq 'pending' && $old ne 'pending') {
    $self->errors->add($attribute_name, "can't return to pending", $opt);
  }
  if($old eq 'completed' && $value ne 'completed') {
    $self->errors->add($attribute_name, "task is already finished", $opt);
  }
  if ($old eq 'on_hold' && $value ne 'completed') {
    $self->errors->add($attribute_name, "on hold can't change to completed", $opt);
  }
  if ($old eq 'blocked' && $value ne 'completed') {
    $self->errors->add($attribute_name, "blocked can't change to completed", $opt);
  }  
}

1;