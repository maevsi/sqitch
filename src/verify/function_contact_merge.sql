BEGIN;

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.contact_merge(UUID, UUID, vibetype.contact)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on contact_merge';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.contact_merge(UUID, UUID, vibetype.contact)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous has EXECUTE privilege on contact_merge';
  END IF;
END $$;

ROLLBACK;
