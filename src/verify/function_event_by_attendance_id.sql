BEGIN;

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_by_attendance_id(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'vibetype_account does not have EXECUTE privilege';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_by_attendance_id(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'vibetype_anonymous does not have EXECUTE privilege';
  END IF;
END $$;

ROLLBACK;
