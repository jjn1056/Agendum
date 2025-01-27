package Agendum::Schema::Result::Task;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("tasks");

__PACKAGE__->add_columns(
  task_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  person_id => { data_type => 'integer', is_nullable => 0 },
  title => { data_type => 'varchar', is_nullable => 0, size => 255 },
  description => { data_type => 'text', is_nullable => 1 },
  due_date => { data_type => 'date', is_nullable => 1 },
  priority => { data_type => 'integer', is_nullable => 1, default_value => 1 },
  status => { data_type => 'varchar', is_nullable => 1, size => 50, default_value => 'pending', track_storage => 1 },
  created_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
);

__PACKAGE__->set_primary_key("task_id", "person_id");

__PACKAGE__->belongs_to(
  task => 'Agendum::Schema::Result::Task',
  {
    'foreign.task_id' => 'self.task_id'
  }
);

__PACKAGE__->has_many(
  comments => 'Agendum::Schema::Result::Comment',
  {
    'foreign.task_id' => 'self.task_id',
    'foreign.person_id' => 'self.person_id',
  }
);

__PACKAGE__->has_many(
  task_labels => 'Agendum::Schema::Result::TaskLabel',
  { 'foreign.task_id' => 'self.task_id',  'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->many_to_many('labels', 'task_labels', 'label');

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
      min_eq => sub { pop->today },
      if => 'is_column_changed', 
    }
  )
);

sub status_list {
  return qw(pending in_progress on_hold blocked canceled completed);
}

sub valid_status($self, $attribute_name, $value, $opt) {
  my $old = $self->get_column_storage($attribute_name);

  # If the task is not pending, it can't return to pending
  if($value eq 'pending' && $old ne 'pending') {
    $self->errors->add($attribute_name, "can't return to pending", $opt);
  }

  # If the task is completed, it can't change to any other status
  if($old eq 'completed' && $value ne 'completed') {
    $self->errors->add($attribute_name, "task is already finished", $opt);
  }

  # If the tas is on hold or blocked, it can't be moved to completed
  if ($old eq 'on_hold' && $value eq 'completed') {
    $self->errors->add($attribute_name, "on hold can't change to completed", $opt);
  }
  if ($old eq 'blocked' && $value eq 'completed') {
    $self->errors->add($attribute_name, "blocked can't change to completed", $opt);
  }  
}

sub has_new_comment($self) {
  return grep {
    !$_->in_storage
  } $self->comments->all;
}

sub apply_request($self, $req) {


  my $data = +{
    title => $req->title,
    description => $req->description,
    due_date => $req->due_date,
    priority => $req->priority,
    status => $req->status,
    task_labels => [
      map { {label_id => $_->label_id} }  @{$req->get('task_labels')}
    ],
    comments => [
      map { 
        {
          comment_id => $_->comment_id,
          content => $_->content,
          ($_->get('_add') ? (_add => $_->get('_add')) : ()),
        } 
      } @{$req->get('comments')}
    ],
  };
  
  use Devel::Dwarn;
  Dwarn $data;
  Dwarn $req->nested_params;

  $self->set_columns_recursively($req->nested_params)->insert_or_update;
  return $self;
}

1;
