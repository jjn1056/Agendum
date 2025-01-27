package Agendum::Controller::Tasks::Task;

use CatalystX::Object;
use Agendum::Syntax;
use Types::Standard qw(Int);

extends 'Agendum::Controller';

has_shared 'tasks';
has 'task' => (is=>'rw');

# ANY /tasks/...
sub root :At('/...') Via('../root') ($self, $c) { }

  ### CREATE ACTIONS ###

  # ANY /tasks/...
  sub build :At('/...') Via('root') ($self, $c) {
    $self->task($self->tasks->new_task);
  }

    # ANY /tasks/create/...
    sub setup_create :At('create/...') Via('build') ($self, $c) {
      $self->view_for('create', task => $self->task);
    }

      # GET /tasks/create
      sub show_create :Get('') Via('setup_create') ($self, $c) { return }

      # POST /tasks/create
      sub create :Post('') Via('setup_create') BodyModel() QueryModel() ($self, $c, $rm, $q) {
        return $self->process_request($rm, $q);
      }

  # ANY /tasks/$id/...
  sub find :At('{:Int}/...') Via('root') ($self, $c, $task_id) {
    my $task = $self->tasks->find({task_id=>$task_id})
      // return $c->detach_error(404);
    $self->task($task);
  }

    ### UPDATE ACTIONS ###

    # ANY /tasks/$id/update/...
    sub setup_update :At('update/...') Via('find') ($self, $c) {
      $self->view_for('update', task => $self->task);
    }

      # GET /tasks/$id/update
      sub show_update :Get('') Via('setup_update') ($self, $c) { return }

      # PATCH /tasks/$id/update
      sub update :Patch('') Via('setup_update') BodyModelFor('create') QueryModelFor('create') ($self, $c, $rm, $q) {
        return $self->process_request($rm, $q);
      }

    ### DELETE AND DISPLAY ACTIONS ###

    # GET /tasks/$id
    sub show :Get('') Via('find') ($self, $c) {
      return $self->view(task => $self->task);
    }

    # DELETE /tasks/$id
    sub delete :Delete('') Via('find') ($self, $c) {
      return $self->task->delete && $c->redirect_to_action('../list');
    }

### SHARED METHODS ###

sub process_request($self, $rm, $q) {
  $self->task->apply_request($rm);
  return $self->task->validate if $q->add_empty_comment;
  $self->task->insert_or_update;
  $self->view->saved(1) if $self->task->valid;
}

__PACKAGE__->meta->make_immutable;