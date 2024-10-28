package Agendum::View::HTML::Home::Index;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Welcome to Agendum' }

__PACKAGE__->meta->make_immutable;
__DATA__
%= view('HTML::Navbar', active_link=>'home')
<div>
  <h1>Welcome to Agendum!!</h1>
</div>
