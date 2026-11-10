BEGIN;

DROP POLICY attendance_insert ON vibetype.attendance;
DROP POLICY attendance_update ON vibetype.attendance;
DROP POLICY guest_delete ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;

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

CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  EXISTS (
    SELECT 1
      FROM vibetype.event e
      WHERE e.id = guest.event_id
        AND e.created_by = vibetype.invoker_account_id()
  )
);

CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
      FROM vibetype.event e
      WHERE e.id = guest.event_id
        AND e.created_by = vibetype.invoker_account_id()
  )
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

DROP FUNCTION vibetype_private.guests_organized_unblocked();

COMMIT;
