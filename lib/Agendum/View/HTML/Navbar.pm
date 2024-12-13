package Agendum::View::HTML::Navbar;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

has active_link => (is=>'ro', required=>1);

sub navlinks ($self) {
  my @links = (
    +{ href => $self->ctx->uri('/home/index'), data => {title=>'Home', key=>'home'} },
    +{ href => $self->ctx->uri('/tasks/list'), data => {title=>'Tasks', key=>'task_list'} },
  );
  return @links;
}

sub generate_navlinks ($self, $cb) {
  my @links = ();
  foreach my $link ($self->navlinks) {
    my $active = $self->active_link eq $link->{data}{key} ? 'active' : '';
    push @links, $cb->($active, $link->{href}, $link->{data}{title});
  }
  return $self->safe_concat(@links);
}

__PACKAGE__->meta->make_immutable;
__DATA__
<nav class="navbar navbar-expand-lg bg-body-tertiary">
  <div class="container-fluid">
    <a class="navbar-brand" href="#">Agendum</a>
    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav" aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
      <span class="navbar-toggler-icon"></span>
    </button>
    <div class="collapse navbar-collapse" id="navbarNav">
      <ul class="navbar-nav"><%= $self->generate_navlinks(sub ($active, $link, $title) { %>
        <li class="nav-item">
          <a class="nav-link <%= $active %>" aria-current="page" href="<%= $link %>">
            <%= $title %>
          </a>
        </li>
      <% }) %></ul> 
    </div>
  </div>
</nav>