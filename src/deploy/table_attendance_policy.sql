BEGIN;

GRANT SELECT, INSERT, UPDATE ON TABLE vibetype.attendance TO vibetype_account;
GRANT SELECT, UPDATE ON TABLE vibetype.attendance TO vibetype_anonymous;

ALTER TABLE vibetype.attendance ENABLE ROW LEVEL SECURITY;

-- Only the organizer can view all attendance for their events;
-- anyone with an attendance claim can view that specific attendance.
-- guests can view their own attendance via guest claims;
-- signed-in guests can view attendance linked to a contact that refers to them.
-- Helper: returns attendance IDs where the guest belongs to an event organized by the invoker.
-- Needs SECURITY DEFINER to bypass RLS on attendance, guest, and event tables.
CREATE FUNCTION vibetype_private.attendance_via_own_events() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[])
  FROM vibetype.attendance a
  JOIN vibetype.guest g ON g.id = a.guest_id
  JOIN vibetype.event e ON e.id = g.event_id
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

-- Helper: returns attendance IDs where the guest's contact refers to the invoker's account.
-- Needs SECURITY DEFINER to bypass RLS on attendance, guest, and contact tables.
CREATE FUNCTION vibetype_private.attendance_via_own_contact() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[])
  FROM vibetype.attendance a
  JOIN vibetype.guest g ON g.id = a.guest_id
  JOIN vibetype.contact c ON c.id = g.contact_id
  WHERE c.account_id = vibetype.invoker_account_id()
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.created_by);
$$;

-- Row-level visibility check for newly inserted attendance not yet visible to STABLE functions.
-- Only queries guest, event, and contact tables (not attendance), so works during INSERT+RETURNING.
CREATE FUNCTION vibetype_private.attendance_row_visible(guest_id UUID) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT (
    EXISTS (
      SELECT 1
      FROM vibetype.guest g
      JOIN vibetype.event e ON e.id = g.event_id
      WHERE g.id = attendance_row_visible.guest_id
        AND e.created_by = vibetype.invoker_account_id()
    )
    OR EXISTS (
      SELECT 1
      FROM vibetype.guest g
      JOIN vibetype.contact c ON c.id = g.contact_id
      WHERE g.id = attendance_row_visible.guest_id
        AND c.account_id = vibetype.invoker_account_id()
        AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.created_by)
    )
  );
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.attendance_via_own_events() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.attendance_via_own_contact() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.attendance_row_visible(UUID) TO vibetype_account, vibetype_anonymous;

CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.attendance_claim_array()) AS ac WHERE ac = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.attendance_via_own_events()) AS a WHERE a = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.attendance_via_own_contact()) AS a WHERE a = attendance.id)
  OR vibetype_private.attendance_row_visible(attendance.guest_id)
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
