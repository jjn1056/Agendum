package Agendum::View::HTML::Profile::Update;

use CatalystX::Object;
use Agendum::Syntax;

extends 'Agendum::View::HTML::Page';

has user_profile => (is=>'ro', required=>1);

sub title ($self) { return 'Profile' }

sub if_saved($self, $cb) { 
  return '';
}
__PACKAGE__->meta->make_immutable;
__DATA__
#
# Custom Styles
#
% push_style(sub {
% })
#
# Main Content: Task List
#
%= view('HTML::Navbar', active_link=>'profile')
<div class="container-md mt-5 mb-5 mx-auto">
  %= $self->form_for('user_profile', { action=>$c->uri('update') }, sub ($self, $fb, $user) {

    # From user table
    <fieldset class="mb-4">
      %= $fb->legend('User Information',{class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})

      # Messages and global errors
      %= $fb->model_errors(+{class=>'alert alert-danger', role=>'alert', show_message_on_field_errors=>'Please fix validation errors'})
      %= $self->if_saved(sub {
        <div class="alert alert-success" role="alert">Successfully Updated</div>
      % })

      <div class="row g-2">
        # given_name
        <div class="col-sm-4 col-md-3">
          $fb->label('given_name', {class=>"form-label"})
          $fb->input('given_name', {class=>"form-control", errors_classes=>"is-invalid"})
          $fb->errors_for('given_name', {show_empty=>1, class=>"invalid-feedback"})
        </div>

        # family_name
        <div class="col-sm-8 col-md-5">
          $fb->label('family_name', {class=>"form-label"})
          $fb->input('family_name', {class=>"form-control", errors_classes=>"is-invalid"})
          $fb->errors_for('family_name', {show_empty=>1, class=>"invalid-feedback"})
        </div>

        # email
        <div class="col-sm-12 col-md-4">
          $fb->label('email', {class=>"form-label"})
          $fb->input('email', {class=>"form-control", autocomplete=>"false", errors_classes=>"is-invalid"})
          $fb->errors_for('email', {show_empty=>1, class=>"invalid-feedback"})
        </div>
      </div>

    </fieldset>

    # from profile
    <fieldset class="mb-4">

      %= $fb->legend('Profile', {class=>"text-muted fs-5 mb-2 pb-1 border-bottom"})
      %= $fb->errors_for('profile', +{ class=>'alert alert-danger', role=>'alert' })
      %= $fb->fields_for('profile', sub ($self, $fb_profile, $profile) {

        <div class="row mb-3 g-3">
          # address
          <div class="col-md col-sm-8">
            $fb_profile->label('address', {class=>"form-label"})
            $fb_profile->input('address', {class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('address', {show_empty=>1, class=>"invalid-feedback"})
          </div>

          # city
          <div class="col-md-3 col-sm-4">
            $fb_profile->label('city', {class=>"form-label"})
            $fb_profile->input('city', {class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('city', {show_empty=>1, class=>"invalid-feedback"})
          </div>

          # state_id
          <div class="col-md-2 col-sm-6">
            $fb_profile->label('state_id', {class=>"form-label"})
            $fb_profile->collection_select('state_id', $self->user_profile->viewable_states, state_id=>'name', +{ include_blank=>1, class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('state_id', {show_empty=>1, class=>"invalid-feedback"})
          </div>

          # zip
          <div class="col-md-2 col-sm-6">
            $fb_profile->label('zip', {class=>"form-label"})
            $fb_profile->input('zip', {class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('zip', {show_empty=>1, class=>"invalid-feedback"})
          </div>
        </div>

        <div class="row mb-3 g-3">
          # phone_number
          <div class="col-md-4 col-sm-6">
            $fb_profile->label('phone_number', {class=>"form-label"})
            $fb_profile->input('phone_number', {class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('phone_number', {show_empty=>1, class=>"invalid-feedback"})
          </div>

          # birthday
          <div class="col-md-4 col-sm-6">
            $fb_profile->label('birthday', {class=>"form-label"})
            $fb_profile->date_field('birthday', {class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('birthday', {show_empty=>1, class=>"invalid-feedback"})
          </div>

          # employment_id
          <div class="col-md-4 col-sm-12">
            $fb_profile->label('employment_id', {class=>"form-label"})
            $fb_profile->collection_select('employment_id', $self->user_profile->viewable_employment, employment_id=>'label', {include_blank=>1, class=>"form-control", errors_classes=>"is-invalid"})
            $fb_profile->errors_for('employment_id', {show_empty=>1, class=>"invalid-feedback"})
          </div>
        </div>

      % })
    </fieldset>

    $fb->submit('Update Profile',{class=>"btn btn-primary w-100 mb-2"})
  % })
</div>
