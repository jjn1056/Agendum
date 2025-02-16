package Agendum::Controller::Profile;

use CatalystX::Object;
use Agendum::Syntax;

extends 'Agendum::Controller';

has 'user_profile' => (is => 'rw');

# ANY /profile/...
sub root :At('profile/...') Via('../private')  ($self, $c) {
  $self->user_profile($c->user->with_profile); 
}

  # ANY /profile/update/...
  sub setup_update :At('update/...') Via('root') ($self, $c) {
    $self->view_for('update', user_profile => $self->user_profile);
  }

    # GET /profile/update
    sub show_update :Get('') Via('setup_update') ($self, $c) { 
      return;
    }

    # PATCH /profile/update
    sub update :Patch('') Via('setup_update') BodyModel() ($self, $c, $bm) {
      my $data = $bm->as_data([
        'email', 'given_name', 'family_name',
        { profile => [
          'address', 'city', 'state_id', 'zip',
          'phone_number', 'birthday', 'employment_id'
        ] },
      ]);
      return $self->user_profile->apply($data);
    }

__PACKAGE__->meta->make_immutable;
