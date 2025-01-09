-- Revert agendum:user from pg

BEGIN;

-- Drop triggers
DROP TRIGGER IF EXISTS trigger_update_person_updated_at ON person;

-- Drop tables
DROP TABLE IF EXISTS person;

COMMIT;
