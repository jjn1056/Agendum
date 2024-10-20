package Agendum::View::HTML::Home::Index;

use Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

__PACKAGE__->meta->make_immutable;
__DATA__
% $self->view('HTML::Page', { title => 'Home' }, sub($page) {
%   $self->view('HTML::Navbar', { active_link=>'home' }),
    <div>
      <h1>Welcome to Agendum</h1>
    </div>
% });