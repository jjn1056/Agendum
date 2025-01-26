package Agendum::View::HTML::Tasks::Task::Create;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has task => ( is => 'ro', required => 1, export => 1 );
has saved => ( is => 'rw', required => 1, default => 0, export => 1 );

sub title ($self) { return 'New Task' }

__PACKAGE__->meta->make_immutable;
__DATA__
# Custom Styles
% push_style(sub {
  /* Ensure the checkbox list wraps properly */
  .checkbox-list {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
  }
% })
# Main Content
%= view('HTML::Navbar', active_link=>'task_list')
<div class="container col-8 mt-5 mb-5">
  %= view('HTML::Tasks::Task::_Form', task=>$task, saved=>$saved)
</div>
