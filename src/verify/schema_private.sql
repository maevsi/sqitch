BEGIN;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_schema_privilege('vibetype_account', 'vibetype_private', 'USAGE'));
  ASSERT NOT (SELECT pg_catalog.has_schema_privilege('vibetype_anonymous', 'vibetype_private', 'USAGE'));
END $$;

ROLLBACK;
