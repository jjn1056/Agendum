package Agendum::ActionRole::Authenticated;

use Moose::Role;

requires 'match', 'match_captures';

around ['match','match_captures'] => sub {
  my ($orig, $self, $ctx, @args) = @_; 
  return $self->$orig($ctx, @args) if $ctx->user->authenticated;
  return 0;
};

1;
