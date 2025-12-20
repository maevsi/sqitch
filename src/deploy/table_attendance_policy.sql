BEGIN;

GRANT SELECT, INSERT, UPDATE ON TABLE vibetype.attendance TO vibetype_account;
GRANT SELECT, UPDATE ON TABLE vibetype.attendance TO vibetype_anonymous;

ALTER TABLE vibetype.attendance ENABLE ROW LEVEL SECURITY;

-- Only the organizer can view all attendance for their events;
-- guests can view their own attendance via guest claims;
-- signed-in guests can view attendance linked to a contact that refers to them.
CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.event e ON e.id = g.event_id
    WHERE g.id = vibetype.attendance.guest_id
      AND e.created_by = vibetype.invoker_account_id()
  )
  OR
  EXISTS (
    SELECT 1
    FROM unnest(vibetype.guest_claim_array()) gc(id)
    WHERE gc.id = vibetype.attendance.guest_id
  )
  OR
  EXISTS (
    SELECT 1
    FROM vibetype.guest g
    JOIN vibetype.contact c ON c.id = g.contact_id
    WHERE g.id = vibetype.attendance.guest_id
      AND c.account_id = vibetype.invoker_account_id()
      AND c.created_by NOT IN (SELECT id FROM vibetype_private.account_block_ids())
  )
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
  OR
  EXISTS (
    SELECT 1
    FROM unnest(vibetype.guest_claim_array()) gc(id)
    WHERE gc.id = vibetype.attendance.guest_id
  )
);

COMMIT;
