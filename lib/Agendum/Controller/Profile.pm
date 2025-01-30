package Agendum::Controller::Profile;

use CatalystX::Object;
use Agendum::Syntax;

extends 'Agendum::Controller';

has 'user_profile' => (
  is=>'ro', 
  required=>1,
  lazy=>1,
  default=>sub($self, $c) {
    return my $up = $c->user->with_profile;
  },
);

# ANY /profile/...
sub root :At('profile/...') Via('../private')  ($self, $c) { }

  # ANY /profile/update/...
  sub setup_update :At('update/...') Via('root') ($self, $c) {
    $self->view_for('update', user_profile => $self->user_profile);
  }

    # GET /profile/update
    sub show_update :Get('') Via('setup_update') ($self, $c) { return }

    # PATCH /profile/update
    sub update :Patch('') Via('setup_update') BodyModel() ($self, $c, $bm) {
      return $self->user_profile->apply($bm->nested_params);
    }

__PACKAGE__->meta->make_immutable;
