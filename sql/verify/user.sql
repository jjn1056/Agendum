-- Verify agendum:user on pg

BEGIN;

-- Verify that the 'person' table and its columns exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'person') THEN
        RAISE EXCEPTION 'Table person does not exist';
    END IF;

    PERFORM column_name
    FROM information_schema.columns
    WHERE table_name = 'person'
      AND column_name IN ('person_id', 'public_id', 'email', 'given_name', 'family_name', 'phone_number', 'picture', 'created_at', 'updated_at');

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Table person is missing required columns';
    END IF;
END;
$$;

-- Verify triggers exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_update_person_updated_at') THEN
        RAISE EXCEPTION 'Trigger trigger_update_person_updated_at does not exist';
    END IF;
END;
$$;

ROLLBACK;
