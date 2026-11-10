BEGIN;

-- `attendance_row_visible(guest_id)` ran once for every attendance row the
-- array checks rejected. Matching `attendance.guest_id` against guest arrays
-- covers the same rows, including an attendance inserted by the current
-- statement (INSERT ... RETURNING), since its guest already exists.

-- Helper: returns guest IDs for events organized by the invoker.
-- Needs SECURITY DEFINER to bypass RLS on guest and event tables.
CREATE FUNCTION vibetype_private.guests_via_own_events() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  JOIN vibetype.guest g ON g.event_id = e.id
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_events() TO vibetype_account, vibetype_anonymous;

DROP POLICY attendance_select ON vibetype.attendance;

-- Only the organizer can view all attendance for their events;
-- anyone with an attendance claim can view that specific attendance.
-- guests can view their own attendance via guest claims;
-- signed-in guests can view attendance linked to a contact that refers to them.
CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.attendance_claim_array()) AS ac WHERE ac = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events()) AS g WHERE g = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = attendance.guest_id)
);

DROP FUNCTION vibetype_private.attendance_row_visible(UUID);
DROP FUNCTION vibetype_private.attendance_via_own_contact();
DROP FUNCTION vibetype_private.attendance_via_own_events();

COMMIT;
