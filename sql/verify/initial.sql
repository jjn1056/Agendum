-- Verify contactsdemo:initial on sqlite

BEGIN;

select 1 from tasks limit 1;
select 1 from labels limit 1;
select 1 from comments limit 1;
select 1 from task_labels limit 1;

ROLLBACK;
