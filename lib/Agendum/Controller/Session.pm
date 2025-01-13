package Agendum::Controller::Session;

use CatalystX::Moose;
use Agendum::Syntax;

extends 'Agendum::Controller';

## ANY /...
sub root :At('/...') Via('../public') ($self, $c) { }

  ## GET /login
  sub login :Get('login') Via('root') ($self, $c) {

    # Show a 'login' page.  This is just a page with a form that
    # posts to action 'redirect_to_authorize' I start the OAuth2
    # flow this way so that we avoid have to put the 'state' in
    # a link the authorization endpoint. This stops people from
    # clicking 'back' and then getting a link with a stale state.

    return $self->view(post_url => $c->uri('redirect_to_authorize'));
  }

 sub redirect_to_authorize :Post('login') Via('root') ($self, $c) {

    # Generate a unique state, put it into the session and then
    # get the authorize link using that state and the target redirect_uri
    # (which is this the 'callback' action in this controller).

    my $state = $c->model('Session')->generate_oauth2_state;
    my $authorize_link = $c->model('WebService::Catme::Auth')
      ->authorize_link($c->uri('callback'), $state);

    $c->log->debug("Redirecting to: $authorize_link");
    return $c->res->redirect($authorize_link);
  }

  ## GET /callback
  sub callback :Get('callback') Via('root') ($self, $c) {

    # This is the 'redirect_uri' target for the OAuth2 flow.  We need to
    # check the state and then get the tokens from the code and set the
    # session with the access and refresh tokens.  This all get initiated
    # from the 'login' action.

    # Check for any errors from the OAuth2 server
    $c->detach_error(400, +{error => $c->req->parameters->{'error_description'}})
      if $c->req->parameters->{'error'};

    # Error if the state doesn't match
    $c->detach_error(400, +{error => "Invalid 'state' returned from OAuth2 server."})
      unless $c->model('Session')->check_oauth2_state($c->req->param('state'));

    # Get the tokens or return an error if we can't
    my ($tokens, $err) = $c->model('WebService::Catme::Auth')
      ->get_tokens_from_code($c->req->parameters->{'code'}, $c->uri_for('callback'));
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

__PACKAGE__->meta->make_immutable;
