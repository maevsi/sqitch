BEGIN;

DO $$
BEGIN
  ASSERT EXISTS(SELECT * FROM pg_catalog.pg_namespace WHERE nspname = 'vibetype_test');
END $$;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype_test', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype_test', 'USAGE'));
END $$;

ROLLBACK;
