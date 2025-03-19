BEGIN;

GRANT SELECT, INSERT ON vibetype.invitation TO vibetype_account;

ALTER TABLE vibetype.invitation ENABLE ROW LEVEL SECURITY;

CREATE POLICY invitation_select ON vibetype.invitation FOR SELECT USING (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY invitation_insert ON vibetype.invitation FOR INSERT WITH CHECK (
  created_by = vibetype.invoker_account_id()
  AND
  vibetype.invoker_account_id() = (
    SELECT e.created_by
    FROM vibetype.guest g
      JOIN vibetype.event e ON g.event_id = e.id
    WHERE g.id = guest_id
  )
);

COMMIT;
