package Agendum::View::HTML::Tasks::List;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has tasks => (is=>'ro', required=>1);
#has sort_column => (is=>'ro', required=>1);
#has sort_direction => (is=>'ro', required=>1);

sub title ($self) { return 'Your Tasks' }

sub priority ($self, $task) {
  return $task->priority;
}

sub due_date ($self, $task) {
  my $date = $task->due_date->strftime('%Y-%m-%d');

  # If a task is overdue, highlight it
  if(DateTime->today > $task->due_date ) {
    return $self->raw("<span class='bi bi-exclamation-circle text-danger'>&nbsp;$date</span>");
  } 

  # If a task is due in the next three days, highlight it
  if(DateTime->today->add(days=>3) >$task->due_date ) {
    return $self->raw("<span class='bi bi-clock text-dark'>&nbsp;$date</span>");
  }

  return $self->raw("<span class='bi bi-check-circle text-success'>&nbsp;$date</span>");
}

sub status ($self, $task) {
  return $task->human_label_name($task->status);
}

sub over_tasks ($self, $cb) {
  my @display_tasks = map {
    +{
      id => $_->task_id,
      title => $_->title,
      priority => $self->priority($_),
      due_date => $self->due_date($_),
      status => $self->status($_),
      edit_url => $self->ctx->uri('task/update', [$_->task_id]),
      show_url => $self->ctx->uri('task/show', [$_->task_id]),
    }
  } $self->tasks->all;
  return $self->over(@display_tasks, $cb);
}

sub nav_line ($self, $pager, $cb) {
  my $nav_line = $pager->navigation_line;
  return '' unless $nav_line;
  return $cb->($nav_line);
}

__PACKAGE__->meta->make_immutable;
__DATA__
#
# Custom Styles
#
% push_style(sub {
    .pager_current_page {
      font-weight: bold;
    }
    .pager_page {
      margin: 0 5px;
    }
    .table .no-border-stripes {
      --bs-table-bg-type: transparent !important;
      border: none;
    }

    .table thead th:not(:nth-last-child(-n+2)) {
      position: relative;
    }
    .table thead th:not(:nth-last-child(-n+2))::after {
      content: "";
      position: absolute;
      top: 25%;
      bottom: 25%;
      right: 0;
      width: 1px;
      background-color: #dee2e6;
    }

    /* sorting */
    .sort-icon {
      margin-left: 0.25rem;
      font-size: 0.9rem;
    } 
    th.sortable {
      position: relative;
      cursor: pointer;
      user-select: none;
    }
% })
#
# Main Content: Task List
#
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container col-8 mt-5 mx-auto">
  %= pager_for('tasks', +{}, sub ($self, $pager, $tasks) {
    <table class='table table-striped'>
      <legend class="text-muted fs-5 mb-2 pb-1 border-bottom">$pager->window_info</legend>
      <thead>
        <tr>
          <th scope="col" role="button">Title<i class="bi bi-caret-up-fill sort-icon"></i></th>
          <th scope="col">Priority</th>
          <th scope="col">Due Date</th>
          <th scope="col">Status</th>
          <th scope="col" class="visually-hidden">Actions</th>
        </tr>
      </thead>

      # Display the tasks
      <tbody>
        %= $self->over_tasks(sub ($task, $inf) {
          <tr>
            <td><a href="$task->{show_url}">$task->{title}</a></td>
            <td>$task->{priority}</td>
            <td>$task->{due_date}</td>
            <td>$task->{status}</td>
            <td class="pb-1 pt-1 ps-3 no-border-stripes">
              <a href="$task->{edit_url}" class="btn btn-sm btn-primary">Edit</button>
            </td>
          </tr>
        % })
      </tbody>

      # Display the navigation line (if needed)
      %= $self->nav_line($pager, sub ($nav_line) {
        <tfoot>
          <tr>
            <td colspan="4" style="--bs-table-bg-type: transparent;border: none;">
              $nav_line
            </td>
          </tr>
        </tfoot>
      % })
    </table>
  % })
  <div class="mt-4 mb-4">
  <a href="$self->ctx->uri('task/create')" class="btn btn-primary w-100">Add Task</a>
  </div>
</div>