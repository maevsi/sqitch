BEGIN;

CREATE FUNCTION vibetype_private.attendance_via_own_events() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[])
  FROM vibetype.attendance a
  JOIN vibetype.guest g ON g.id = a.guest_id
  JOIN vibetype.event e ON e.id = g.event_id
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

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

DROP POLICY attendance_select ON vibetype.attendance;

CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.attendance_claim_array()) AS ac WHERE ac = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.attendance_via_own_events()) AS a WHERE a = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.attendance_via_own_contact()) AS a WHERE a = attendance.id)
  OR vibetype_private.attendance_row_visible(attendance.guest_id)
);

DROP FUNCTION vibetype_private.guests_via_own_events();

COMMIT;
