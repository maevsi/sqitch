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
CREATE FUNCTION vibetype_private.event_policy_select()
RETURNS SETOF vibetype.event AS $$
  SELECT * FROM vibetype.event e
  WHERE (
    (
      e.visibility = 'public'
      AND (
        e.guest_count_maximum IS NULL
        OR e.guest_count_maximum > vibetype.guest_count(e.id)
      )
      AND NOT EXISTS (
        SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
      )
    )
    OR (
      e.id IN (
        SELECT * FROM vibetype_private.events_invited()
      )
    )
  );
$$ LANGUAGE sql STABLE STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_private.event_policy_select() TO vibetype_account, vibetype_anonymous;

CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
  id IN (SELECT id FROM vibetype_private.event_policy_select())
);

COMMIT;
