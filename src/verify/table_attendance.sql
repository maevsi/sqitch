BEGIN;

SELECT id,
       checked_out,
       contact_id,
       guest_id,
       created_at,
       updated_at,
       updated_by
FROM vibetype.attendance WHERE FALSE;

DO $$
BEGIN
  ASSERT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_trigger t
    WHERE t.tgname = 'vibetype_trigger_attendance_metadata_update'
  );
END $$;

DO $$
BEGIN
  ASSERT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_trigger t
    WHERE t.tgname = 'vibetype_trigger_attendance_guard'
  );

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.attendance_guard()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.attendance_guard()', 'EXECUTE'));
END $$;

ROLLBACK;
