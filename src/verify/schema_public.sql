BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype', 'USAGE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege('vibetype_tusd', 'vibetype', 'USAGE'));
END $$;

ROLLBACK;
