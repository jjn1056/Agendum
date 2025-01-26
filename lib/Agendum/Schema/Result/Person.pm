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


__PACKAGE__->validates(email => presence=>1, length=>[3,24], format=>'email', unique=>1);
__PACKAGE__->validates( password => (presence=>1, length=>[3,24], confirmation => 1,  on=>'create' ));
__PACKAGE__->validates( password => (confirmation => { 
    on => 'update',
    if => 'is_column_changed', # This method defined by DBIx::Class::Row
}));

__PACKAGE__->validates(given_name => (presence=>1, length=>[2,24]));
__PACKAGE__->validates(family_name => (presence=>1, length=>[2,48]));

sub authenticated ($self) {
  return $self->in_storage;
}

sub authenticate($self, $email, $password) {
  my $found = $self->result_source->resultset->find({email=>$email});
  if($found && $found->check_password($password)) {
    %$self = %$found;
    return $self;
  } else {
    $self->errors->add(undef, 'Invalid login credentials');
    $self->username($username) if defined($username);
    return 0;
  }
}

sub registered($self) {
  return $self->email &&
    $self->given_name &&
    $self->family_name &&
    $self->password &&
    $self->in_storage ? 1:0;
}

sub register($self, $request) {
  $self->set_columns_recursively($request->nested_params)
    ->insert_or_update;
  return $self->registered;
}

1;
