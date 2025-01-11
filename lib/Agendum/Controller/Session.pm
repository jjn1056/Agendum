package Agendum::Controller::Session;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') Via('../public') ($self, $c) { }

  ## GET /callback
  sub callback :Get('callback') Via('root') ($self, $c) {

    # Error if the state doesn't match
    $c->detach_error(400, +{error => "Invalid state."})
      unless $c->model('Session')->check_oauth2_state($c->req->param('state'));
    $c->model('Session')->clear_oauth2_state; # one time use

    # Get the tokens or return an error if we can't
    my ($tokens, $err) = $c->model('WebService::Catme::Auth')
      ->get_tokens_from_code($c->req->param('code'), $c->uri_for('/callback'));
    $c->detach_error(400, +{error => $err}) if $err;

    # Based on the id_token, find or create the Person and set the session
    my $user = $c->model('Session::User')
      ->authenticate_user_from_id_token(%{$tokens->{decoded}{id_token}});
    
    # We need to set the access and refresh tokens in the session
    $c->model('Session')->set_oauth2_tokens(
      $tokens->{access_token},
      $tokens->{refresh_token});

    # Redirect to the user page
    return $c->redirect_to_action('/home/user');
  }

  ## GET /logout
  sub logout :Get('logout') Via('root') ($self, $c) {
    $c->model('Session::User')->logout;
    return $self->view();
  }

  ## GET /login
  sub login :Get('login') Via('root') ($self, $c) {

    # Generate a unique state, put it into the session and then
    # get the authorize link using that state and the target redirect_uri
    # (which is this the 'callback' action in this controller).

    my $state = $c->model('Session')->generate_oauth2_state;
    my $authorize_link = $c->model('WebService::Catme::Auth')
      ->authorize_link($c->uri('callback'), $state);
    return $self->view(authorize_link=>$authorize_link);
  }

# The order of the Action Roles is important!!
sub end :Action Does('RenderErrors') Does('RenderView') { }

__PACKAGE__->meta->make_immutable;
