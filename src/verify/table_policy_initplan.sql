BEGIN;

DO $$
BEGIN
  IF to_regprocedure('vibetype_private.guests_organized_unblocked()') IS NOT NULL
    OR to_regprocedure('vibetype_private.guests_via_own_contact()') IS NOT NULL
    OR to_regprocedure('vibetype_private.guests_via_own_events()') IS NOT NULL THEN
    RAISE EXCEPTION 'Guest id array helpers still exist.';
  END IF;
END $$;

ROLLBACK;
