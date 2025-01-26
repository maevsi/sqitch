BEGIN;

DO $$
BEGIN
  ASSERT EXISTS(SELECT * FROM pg_catalog.pg_namespace WHERE nspname = 'maevsi_test');
END $$;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_account', 'maevsi_test', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('maevsi_anonymous', 'maevsi_test', 'USAGE'));
END $$;

ROLLBACK;
