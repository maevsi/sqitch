BEGIN;

SELECT vibetype_private.contacts_blocked();
SELECT vibetype_private.contacts_referring_invoker();
SELECT vibetype_private.events_organized();

DO $$
BEGIN
  IF to_regprocedure('vibetype_private.guest_row_visible(uuid, uuid)') IS NOT NULL
    OR to_regprocedure('vibetype_private.guests_via_own_events_unblocked()') IS NOT NULL THEN
    RAISE EXCEPTION 'Per-row guest visibility helpers still exist.';
  END IF;
END $$;

ROLLBACK;
