package Agendum::View::HTML::Errors::NotFound;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Not Found' }

has error => (is=>'ro', required=>1);


__PACKAGE__->meta->make_immutable;
__DATA__
%= view('HTML::Navbar')
<div class="container mt-5 mb-5">
  <h1>Not Found</h1>
  <p class="lead">The file references in the request was not found.</p>
  <p>$self->error</p>
</div>