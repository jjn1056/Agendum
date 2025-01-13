package Agendum::View::HTML::Errors::Default;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Error' }

has error => (is=>'ro', required=>1);


__PACKAGE__->meta->make_immutable;
__DATA__
%= view('HTML::Navbar')
<div class="container mt-5 mb-5">
  <h1>Error</h1>
  <p class="lead">The website generated an error.</p>
  <p>$self->error</p>
</div>
