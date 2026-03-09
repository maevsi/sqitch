BEGIN;

GRANT SELECT ON TABLE vibetype.event TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.event TO vibetype_account;

ALTER TABLE vibetype.event ENABLE ROW LEVEL SECURITY;

-- Only allow events that are organized by oneself.
CREATE POLICY event_all ON vibetype.event FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events to which oneself is invited, but not by a guest created by a blocked account.
-- Only display events for which the invoker has a claimed attendance.

-- Helper: returns event IDs for events accessible through attendance claims.
-- Needs SECURITY DEFINER to bypass RLS on attendance and guest tables.
CREATE FUNCTION vibetype_private.events_with_claimed_attendance() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(DISTINCT g.event_id), ARRAY[]::UUID[])
  FROM vibetype.attendance a
  JOIN vibetype.guest g ON g.id = a.guest_id
  WHERE a.id = ANY (vibetype.attendance_claim_array());
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.events_with_claimed_attendance() TO vibetype_account, vibetype_anonymous;

CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
  (
    event.visibility = 'public'
    AND (
      event.guest_count_maximum IS NULL
      OR event.guest_count_maximum > vibetype.guest_count(event.id)
    )
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = event.created_by)
  )
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.events_invited()) AS inv WHERE inv = event.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.events_with_claimed_attendance()) AS att WHERE att = event.id)
);

COMMIT;
