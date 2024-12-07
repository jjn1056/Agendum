use Test::Most;
use Test::DBIx::Class -schema_class => 'Agendum::Schema';

ok my $task = Schema->resultset('Task')->create({
    title => 'A Task',
    description => 'A description',
    due_date => '2000-12-31',
    priority => 1,
    status => 'pending',
    comments => [
        { content => 'A comment' },
        { content => 'A' }, # This comment is too short
    ],
    task_labels => [
       { label => { name => 'not_a_label' } },
    ],
});

is_deeply +{ $task->errors->to_hash(full_messages=>1) }, +{
  comments => [
    "Comments Are Invalid",
  ],
  "comments[1].content" => [
    "Comments Content is too short (minimum is 2 characters)",
  ],
  task_labels => [
    "Task Labels Are Invalid",
  ],
  "task_labels[0].label" => [
    "Task Labels Label Related Model 'Label' Not Found",
  ],
};

done_testing;
