BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.jwt_update_attendance_add(uuid)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.jwt_update_attendance_add(uuid)', 'EXECUTE'));
END $$;

ROLLBACK;
