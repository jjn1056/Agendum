package Agendum::Test;

use CatalystX::Object;
use MooseX::NonMoose;

extends 'Catalyst::Controller';

has 'tasks' => (is => 'rw', to_view=>1);
has 'task' => (is => 'rw', to_view=>1);

package Agendum::Controller::Tasks;

use CatalystX::Object;
use Agendum::Syntax;
use Types::Standard qw(Int);

extends 'Agendum::Controller';

has 'tasks' => (is => 'rw', to_view=>1);
has 'task' => (is => 'rw', to_view=>1);

# ANY /tasks/...
sub root :At('/tasks/...') Via('../private') ($self, $c) {
  $self->tasks($c->user->search_related('tasks')->with_comments_labels);

  use Devel::Dwarn;
  warn '...................';
  my $test = Agendum::Test->new;
  Dwarn $test->view_attributes;
}

  ## LIST ACTIONS

  # GET /tasks/list
  sub list :Get('list') Via('root') QueryModel() ($self, $c, $q) {
    $self->tasks( $self->tasks->page($q->page));
    return $self->view_for('list');
  }

  ## CREATE ACTIONS

  # ANY /tasks/create/...
  sub build :At('/create/...') Via('root') ($self, $c) {
    $self->task($self->tasks->new_task);
    $self->view_for('create');
  }

    # GET /tasks/create
    sub show_create :Get Via('build') ($self, $c) { return }

    # POST /tasks/create
    sub create :Post('') Via('build') BodyModel() ($self, $c, $b) {
      $self->process_request($b);
    }

  ## FIND ACTIONS

  # ANY /tasks/$id/...
  sub find :At('{:Int}/...') Via('root') ($self, $c, $task_id) {
    my $task = $self->tasks->find({task_id=>$task_id}) // return $c->detach_error(404);
    $self->task($task);
  }

    # GET /tasks/$id
    sub show :Get('') Via('find') ($self, $c) {
      return $self->view_for('show');
    }

    # DELETE /tasks/$id
    sub delete :Delete('') Via('find') ($self, $c) {
      return $self->task->delete && $c->redirect_to_action('list');
    }

    ## UPDATE ACTIONS

    # ANY /tasks/$id/update/...
    sub build_update :At('update/...') Via('find') ($self, $c) { 
      $self->view_for('update');
    }

      # GET /tasks/$id/update
      sub show_update :Get('') Via('build_update') ($self, $c) { return }

      # PATCH /tasks/$id/update
      sub update :Patch('') Via('build_update') BodyModelFor('create') ($self, $c, $b) {
        $self->process_request($b);
      }

### SHARED METHODS ###

sub process_request($self, $b) {
  my $data = $b->as_data([
    'title', 'description', 'due_date', 'priority', 'status',
    { task_labels => ['label_id'] },
    { comments => ['content', 'comment_id', '_add', '_delete'] }
  ]);
  $self->task->set_columns_recursively($data);

  return if $b->is_adding_comment;

  $self->task->insert_or_update;
  $self->view->saved(1) if $self->task->valid;
}

__PACKAGE__->meta->make_immutable;
