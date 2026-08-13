BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.outbox_is_acknowledged(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.outbox_is_acknowledged(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
