BEGIN;

GRANT SELECT, INSERT, UPDATE ON TABLE vibetype.attendance TO vibetype_account;
GRANT SELECT, UPDATE ON TABLE vibetype.attendance TO vibetype_anonymous;

ALTER TABLE vibetype.attendance ENABLE ROW LEVEL SECURITY;

-- Only the organizer can view all attendance for their events;
-- anyone with an attendance claim can view that specific attendance.
-- guests can view their own attendance via guest claims;
-- signed-in guests can view attendance linked to a contact that refers to them.
CREATE FUNCTION vibetype_private.attendance_policy_select(a vibetype.attendance)
RETURNS boolean AS $$
  SELECT (
    a.id = ANY(vibetype.attendance_claim_array())
    OR
    EXISTS (
      SELECT 1
      FROM vibetype.guest g
      JOIN vibetype.event e ON e.id = g.event_id
      WHERE g.id = a.guest_id
        AND e.created_by = vibetype.invoker_account_id()
    )
    OR
    a.guest_id = ANY(vibetype.guest_claim_array())
    OR
    EXISTS (
      SELECT 1
      FROM vibetype.guest g
      JOIN vibetype.contact c ON c.id = g.contact_id
      WHERE g.id = a.guest_id
        AND c.account_id = vibetype.invoker_account_id()
        AND NOT (c.created_by = ANY(vibetype_private.account_block_ids()))
    )
  );
$$ LANGUAGE sql STABLE STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_private.attendance_policy_select(vibetype.attendance) TO vibetype_account, vibetype_anonymous;

CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  vibetype_private.attendance_policy_select(attendance)
);

-- Only the organizer may check a guest in (insert attendance).
CREATE POLICY attendance_insert ON vibetype.attendance FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.event e ON e.id = g.event_id
    WHERE g.id = vibetype.attendance.guest_id
      AND e.created_by = vibetype.invoker_account_id()
  )
);

-- Organizer or the guest themself (via JWT claim) may update (e.g., check out).
CREATE POLICY attendance_update ON vibetype.attendance FOR UPDATE
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.event e ON e.id = g.event_id
    WHERE g.id = vibetype.attendance.guest_id
      AND e.created_by = vibetype.invoker_account_id()
  )
  OR vibetype.attendance.guest_id = ANY(vibetype.guest_claim_array())
);

COMMIT;
