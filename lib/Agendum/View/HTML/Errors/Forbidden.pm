package Agendum::View::HTML::Errors::Forbidden;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Forbidden' }

has error => (is=>'ro', required=>1);


__PACKAGE__->meta->make_immutable;
__DATA__
%= view('HTML::Navbar')
<div class="container mt-5 mb-5">
  <h1>Forbidden</h1>
  <p class="lead">You don't have access to this web page.</p>
  <p>$self->error</p>
</div>
