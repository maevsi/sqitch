BEGIN;

GRANT SELECT, INSERT ON maevsi.invitation TO maevsi_account;

ALTER TABLE maevsi.invitation ENABLE ROW LEVEL SECURITY;

CREATE POLICY invitation_select ON maevsi.invitation FOR SELECT USING (
  maevsi.invoker_account_id() = (
    SELECT e.created_by
    FROM maevsi.guest g
      JOIN maevsi.event e ON g.event_id = e.id
    WHERE g.id = guest_id
  )
);

CREATE POLICY invitation_insert ON maevsi.invitation FOR INSERT WITH CHECK (
  created_by = maevsi.invoker_account_id()
  AND
  maevsi.invoker_account_id() = (
    SELECT e.created_by
    FROM maevsi.guest g
      JOIN maevsi.event e ON g.event_id = e.id
    WHERE g.id = guest_id
  )
);

COMMIT;
