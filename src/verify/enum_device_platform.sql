BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_type_privilege('vibetype.device_platform', 'USAGE'));
END $$;

ROLLBACK;
