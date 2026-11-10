BEGIN;

-- The write policies joined `guest` and `event` as the invoker, so planning
-- every write expanded the `guest` and `event` select policies inside them,
-- twice for `attendance_update` as its `USING` doubles as `WITH CHECK`.
-- SECURITY DEFINER arrays keep those policies out of the plan.

-- Helper: returns guest IDs for events organized by the invoker, omitting guests with contacts pointing at or created by a blocked account.
-- Matches the organizer branch of `guest_select`, which the joins inherited.
-- Needs SECURITY DEFINER to bypass RLS on guest and event tables.
CREATE FUNCTION vibetype_private.guests_organized_unblocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.contacts_blocked() AS ids
  )
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  JOIN vibetype.guest g ON g.event_id = e.id,
  _blocked
  WHERE e.created_by = vibetype.invoker_account_id()
    AND NOT (g.contact_id = ANY (_blocked.ids));
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.guests_organized_unblocked() TO vibetype_account, vibetype_anonymous;

DROP POLICY attendance_insert ON vibetype.attendance;
DROP POLICY attendance_update ON vibetype.attendance;
DROP POLICY guest_delete ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;

-- Only the organizer may check a guest in (insert attendance).
CREATE POLICY attendance_insert ON vibetype.attendance FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_organized_unblocked()) AS g WHERE g = attendance.guest_id)
);

-- Organizer or the guest themself (via JWT claim) may update (e.g., check out).
CREATE POLICY attendance_update ON vibetype.attendance FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_organized_unblocked()) AS g WHERE g = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
  AND
  COALESCE(
    vibetype.event_guest_count_maximum(guest.event_id) > vibetype.guest_count(guest.event_id),
    TRUE
  )
  AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = guest.contact_id
      AND c.created_by = vibetype.invoker_account_id()
      AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.account_id)
    )
);

COMMIT;
