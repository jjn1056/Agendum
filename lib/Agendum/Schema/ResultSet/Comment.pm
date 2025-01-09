package Agendum::Schema::ResultSet::Comment;

use DateTime;
use Agendum::Syntax;
use base 'Agendum::Schema::ResultSet';

# If the final comment in the set is not in storage, return true.
sub final_comment_unstored ($self) {
  my @comments = $self->all;
  return 0 if !@comments;
  return $comments[-1]->in_storage ? 0 : 1; # Should be cheap if properly cached
}

1;