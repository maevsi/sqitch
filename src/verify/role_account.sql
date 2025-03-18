BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role('vibetype_postgraphile', 'vibetype_account', 'USAGE'));
  -- Other accounts might not exist yet for a NOT-check.
END $$;

ROLLBACK;
