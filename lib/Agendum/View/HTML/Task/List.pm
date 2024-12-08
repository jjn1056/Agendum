package Agendum::View::HTML::Task::List;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has tasks => (is=>'ro', required=>1);

sub title ($self) { return 'Your Tasks' }

sub priority ($self, $task) {
  return $task->priority;
}

sub due_date ($self, $task) {
  my $date = $task->due_date->strftime('%Y-%m-%d');

  # If a task is due in the next three days, highlight it


  if(DateTime->today > $task->due_date ) {
    return $self->raw("<span class='bi bi-exclamation-circle text-danger'>&nbsp;$date</span>");
  } 

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
      id => $_->id,
      title => $_->title,
      priority => $self->priority($_),
      due_date => $self->due_date($_),
      status => $self->status($_),
      url => $self->ctx->uri('update', [$_->id]),
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
    .list-container {
      max-width: 800px;
    }
    .pager_current_page {
      font-weight: bold;
    }
    .pager_page {
      margin: 0 5px;
    }
% })
#
# Main Content: Task List
#
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container mt-5 list-container">
  %= pager_for('tasks', +{}, sub ($self, $pager, $tasks) {
    <table class='table table-striped table-bordered'>
      <legend class="text-muted fs-5 mb-2 pb-1 border-bottom">$pager->window_info</legend>
      <thead>
        <tr>
          <th>Title</th>
          <th>Priority</th>
          <th>Due Date</th>
          <th>Status</th>
        </tr>
      </thead>

      # Display the tasks
      <tbody>
        %= $self->over_tasks(sub ($task, $inf) {
          <tr>
            <td><a href="$task->{url}">$task->{title}</a></td>
            <td>$task->{priority}</td>
            <td>$task->{due_date}</td>
            <td>$task->{status}</td>
          </tr>
        % })
      </tbody>

      # Display the navigation line (if needed)
      %= $self->nav_line($pager, sub ($nav_line) {
        <tfoot>
          <tr>
            <td colspan="4">
              $nav_line
            </td>
          </tr>
        </tfoot>
      % })
    </table>
  % })
  <div class="mt-4 mb-4">
  <a href="/task/add" class="btn btn-primary w-100">Add Task</a>
  </div>
</div>