package Agendum::View::HTML::Navbar;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::View::HTML';

has active_link => (is=>'ro', predicate=>'has_active_link', required=>0);

sub active_link_eq($self, $link) {
  return '' unless $self->has_active_link;
  return $self->active_link eq $link ? 'active' : '';
}

sub navlinks ($self) {
  my @links = (
    +{ href => $self->ctx->uri('/home/user'), data => {title=>'Home', key=>'home_user'} },
    +{ href => $self->ctx->uri('/profile/show_update'), data => {title=>'Profile', key=>'profile'} },
    +{ href => $self->ctx->uri('/tasks/list'), data => {title=>'Tasks', key=>'task_list'} },
    +{ href => $self->ctx->uri('/session/logout'), data => {title=>'Logout', key=>'logout'} },
  );
  return @links;
}

sub generate_navlinks ($self, $cb) {
  my @links = ();
  if($self->ctx->user->authenticated) {
    foreach my $link ($self->navlinks) {
      push @links, $cb->(
        $self->active_link_eq($link->{data}{key}), 
        $link->{href}, 
        $link->{data}{title}
      );
    }
  } else {
    push @links, $cb->(
      $self->active_link_eq('login'),
      $self->ctx->uri('/session/show'),
      'Login');
    push @links, $cb->(
      $self->active_link_eq('register'),
      $self->ctx->uri('/register/build'),
      'Register');
  }
  return $self->safe_concat(@links);
}

__PACKAGE__->meta->make_immutable;
__DATA__
<nav class="navbar navbar-expand-lg bg-body-tertiary fixed-top">
  <div class="container-fluid">
    <a class="navbar-brand" href="/">Agendum</a>
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