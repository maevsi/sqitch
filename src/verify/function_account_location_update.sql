BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_location_update(DOUBLE PRECISION, DOUBLE PRECISION)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_location_update(DOUBLE PRECISION, DOUBLE PRECISION)', 'EXECUTE'));
END $$;

ROLLBACK;
