BEGIN;

SELECT vibetype_private.guests_via_own_events();

DO $$
BEGIN
  IF to_regprocedure('vibetype_private.attendance_row_visible(uuid)') IS NOT NULL
    OR to_regprocedure('vibetype_private.attendance_via_own_contact()') IS NOT NULL
    OR to_regprocedure('vibetype_private.attendance_via_own_events()') IS NOT NULL THEN
    RAISE EXCEPTION 'Per-row attendance visibility helpers still exist.';
  END IF;
END $$;

ROLLBACK;
