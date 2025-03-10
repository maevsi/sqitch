BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.notification_acknowledge(UUID, BOOLEAN)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.notification_acknowledge(UUID, BOOLEAN)', 'EXECUTE'));
END $$;

ROLLBACK;
