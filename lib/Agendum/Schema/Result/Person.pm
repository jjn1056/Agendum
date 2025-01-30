package Agendum::Schema::Result::Person;

use Agendum::Syntax;
use base 'Agendum::Schema::Result';

__PACKAGE__->table("person");

__PACKAGE__->add_columns(
  person_id => { data_type => 'integer', is_nullable => 0, is_auto_increment => 1 },
  email => { data_type => 'text', is_nullable => 0 },
  given_name => { data_type => 'text', is_nullable => 0 },
  family_name => { data_type => 'text', is_nullable => 0 },
  password => {
    data_type => 'varchar',
    is_nullable => 0,
    size => 64,
    bcrypt => 1,
  },
  created_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
  updated_at => { data_type => 'timestamptz', is_nullable => 1, default_value => \'NOW()' },
  status => { data_type => 'text', is_nullable => 0, default_value => 'pending' },
);

__PACKAGE__->set_primary_key("person_id");
__PACKAGE__->add_unique_constraint(["email"]);

__PACKAGE__->has_many(
  tasks => 'Agendum::Schema::Result::Task',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->has_many(
  comments => 'Agendum::Schema::Result::Comment',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->has_many(
  task_labels => 'Agendum::Schema::Result::TaskLabels',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->might_have(
  profile =>
  'Agendum::Schema::Result::Profile',
  { 'foreign.person_id' => 'self.person_id' }
);

__PACKAGE__->validates(email => presence=>1, length=>[3,24], format=>'email', unique=>1);
__PACKAGE__->validates( password => (presence=>1, length=>[3,24], confirmation => 1,  on=>'create' ));
__PACKAGE__->validates( password => (confirmation => { 
    on => 'update',
    if => 'is_column_changed', # This method defined by DBIx::Class::Row
}));

__PACKAGE__->validates(given_name => (presence=>1, length=>[2,24]));
__PACKAGE__->validates(family_name => (presence=>1, length=>[2,48]));

__PACKAGE__->accept_nested_for('profile');

sub authenticated ($self) {
  return $self->in_storage;
}

## When called via an unauthenticated user, try to authenticate 
## the user with the given email and password. If successful,
## overwrite $self with the found object and return true, otherwise
## add an error to the errors object and return false.

sub validate_credentials($self, $email, $password) {
  %$self = %{$self->result_source->resultset->find_or_new({email=>$email})};
  $self->errors->add(undef, 'Invalid login credentials')
    unless $self->check_password($password);
  return $self;
}

sub registered($self) {
  return $self->email &&
    $self->given_name &&
    $self->family_name &&
    $self->password &&
    $self->in_storage ? 1:0;
}

sub register($self, $registration) {
  $self->set_columns_recursively({
    email => $registration->email,
    given_name => $registration->given_name,
    family_name => $registration->family_name,
    password => $registration->password,
    password_confirmation => $registration->password_confirmation,
    status => 'active', # For now, all registrations are active
  })->insert_or_update;
  return $self;
}

sub with_profile($self) {
  my $profile = $self->self_rs->find(
    { 'me.person_id' => $self->person_id },
    { prefetch => ['profile', {profile=>'state'}, {profile=>'employment'}] }
  );
  $profile->build_related_if_empty('profile'); # Needed since the relationship is optional
  $profile->profile->build_related_if_empty('employment'); # Needed since the relationship is optional
  return $profile;
}

sub apply($self, $params) {
  $self->set_columns_recursively($params)->insert_or_update;
  return $self;
}

## There's are proxied to other resultsets for now but we expect that
## ecentually they could be impacted by the current user.

sub viewable_states {
  my $self = shift;
  return $self->result_source->schema->resultset('State');
}

sub viewable_employment {
  my $self = shift;
  return $self->result_source->schema->resultset('Employment');
}

1;
