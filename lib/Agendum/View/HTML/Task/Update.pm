package Agendum::View::HTML::Task::Update;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has task => ( is => 'ro', required => 1 );

sub title ($self) { return 'Update Task' }

__PACKAGE__->meta->make_immutable;
__DATA__
# Custom Styles
% content_for('css' => sub {
    /* Add a maximum width to the form for desktop screens */
    .form-container {
      max-width: 800px;
    }

    /* Ensure the checkbox list wraps properly */
    .checkbox-list {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }
% })
# Main Content
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container form-container mt-5">
  %= view('HTML::Task::_Form', task=>$self->task)
</div>
