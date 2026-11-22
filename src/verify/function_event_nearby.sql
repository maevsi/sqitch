BEGIN;

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_nearby(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on event_nearby';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_nearby(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege on event_nearby';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_nearby_match(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on event_nearby_match';
  END IF;

  IF (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_nearby_match(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous should not have EXECUTE privilege on event_nearby_match';
  END IF;
END $$;

ROLLBACK;
