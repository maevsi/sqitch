BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.notification_type', 'USAGE'));
END $$;

ROLLBACK;
