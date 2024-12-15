package Agendum::Controller::Tasks::Task;

use CatalystX::Moose;
use Agendum::Syntax;
use Types::Standard qw(Int);

extends 'Agendum::Controller';

# ANY /tasks/...
sub root :At('/...') Via('../root') ($self, $c, $tasks) { $c->action->next($tasks) }

  ### CREATE ACTIONS ###

  # ANY /tasks/...
  sub build :At('/...') Via('root') ($self, $c, $tasks) {
    my $new_task = $tasks->new_task;
    $c->action->next($new_task);
  }

    # ANY /tasks/$id/create/...
    sub setup_create :At('create/...') Via('build') ($self, $c, $new_task) {
      $self->view_for('create', task => $new_task);
      $c->action->next($new_task);
    }

      # GET /tasks/create
      sub show_create :Get('') Via('setup_create') ($self, $c, $new_task) { return }

      # POST /tasks/create
      sub create :Post('') Via('setup_create') BodyModel() QueryModel() ($self, $c, $new_task, $rm, $q) {
        return $self->process_request($new_task, $rm, $q);
      }

  ### UPDATE ACTIONS ###

  # ANY /tasks/$id/...
  sub find :At('{:Int}/...') Via('root') ($self, $c, $tasks, $task_id) {
    my $task = $tasks->find_with_comments_labels($task_id)
      // return $c->detach_error(404);
    $c->action->next($task);
  }

    # GET /tasks/$id
    sub show :Get('') Via('find') ($self, $c, $task) {
      return $self->view(task => $task);
    }

    # DELETE /tasks/$id
    sub delete :Delete('') Via('find') ($self, $c, $task) {
      return $task->delete && $c->redirect_to_action('../list');
    }

    # ANY /tasks/$id/update/...
    sub setup_update :At('update/...') Via('find') ($self, $c, $task) {
      $self->view_for('update', task => $task);
      $c->action->next($task);
    }

      # GET /tasks/$id/update
      sub show_update :Get('') Via('setup_update') ($self, $c, $task) { return }

      # PATCH /tasks/$id/update
      sub update :Patch('') Via('setup_update') BodyModelFor('create') QueryModelFor('create') ($self, $c, $task, $rm, $q) {
        return $self->process_request($task, $rm, $q);
      }

### SHARED METHODS ###

sub process_request($self, $task, $rm, $q) {
  $task->set_columns_recursively($rm->nested_params);
  return $task->validate if $q->add_empty_comment;
  $task->insert_or_update;
  $self->view->saved(1) if $task->valid;
}

__PACKAGE__->meta->make_immutable;