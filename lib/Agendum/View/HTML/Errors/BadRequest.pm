package Agendum::View::HTML::Errors::BadRequest;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

sub title ($self) { return 'Bad Request' }

has error => (is=>'ro', required=>1);


__PACKAGE__->meta->make_immutable;
__DATA__
%= view('HTML::Navbar')
<div class="container mt-5 mb-5">
  <h1>Bad Request</h1>
  <p class="lead">Your request was incorrect.</p>
  <p>$self->error</p>
</div>
