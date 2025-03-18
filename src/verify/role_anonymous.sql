BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role('vibetype_postgraphile', 'vibetype_anonymous', 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
