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
CREATE FUNCTION vibetype_private.event_policy_select(e vibetype.event)
RETURNS boolean AS $$
  SELECT
  (
    (
      e.visibility = 'public'
      AND (
        e.guest_count_maximum IS NULL
        OR e.guest_count_maximum > vibetype.guest_count(e.id)
      )
      AND NOT EXISTS (
        SELECT 1
        FROM vibetype_private.account_block_ids() b
        WHERE b.id = e.created_by
      )
    )
    OR EXISTS (
      SELECT 1
      FROM vibetype_private.events_invited() ei(event_id)
      WHERE ei.event_id = e.id
    )
    OR EXISTS (
      SELECT 1
      FROM vibetype.attendance a
      JOIN vibetype.guest g ON g.id = a.guest_id
      WHERE a.id = ANY (vibetype.attendance_claim_array())
        AND g.event_id = e.id
    )
  );
$$ LANGUAGE sql STABLE STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_private.event_policy_select(vibetype.event) TO vibetype_account, vibetype_anonymous;

CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (vibetype_private.event_policy_select(event));

COMMIT;
