package Agendum::View::HTML::Task::List;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has tasks => (is=>'ro', required=>1);

sub title ($self) { return 'Your Tasks' }

__PACKAGE__->meta->make_immutable;
__DATA__
# Custom Styles
% content_for('css' => sub {
    /* Add a maximum width to the form for desktop screens */
    .list-container {
      max-width: 800px;
    }
% })
# Main Content
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container mt-5 list-container">
  <h1 class="mb-4 text-muted fs-5">Your Tasks</h1> 
  <div class="d-grid gap-3 ">
    # Render a list of tasks as links to update
    % foreach my $task ($self->tasks->all) {
    <div class="card p-3">
      <div class="d-flex justify-content-between align-items-center">
        <a href="/task/update/<%= $task->task_id %>" class="text-decoration-none">
          <h5 class="m-0"><%= $task->title %></h5>
        </a>
      </div>
      <div class="mt-2">
        <span class="badge bg-primary">Priority: <%= $task->priority %></span>
        <span class="badge bg-secondary">Due: <%= $task->due_date %></span>
        <span class="badge bg-info">Status: <%= $task->status %></span>
      </div>
    </div>
    % }
  </div>
  <div class="mt-4">
    <a href="/task/add" class="btn btn-primary w-100">Add Task</a>
  </div>
</div>
