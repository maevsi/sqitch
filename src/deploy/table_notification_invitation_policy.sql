BEGIN;

GRANT SELECT, INSERT ON vibetype.notification_invitation TO vibetype_account;

ALTER TABLE vibetype.notification_invitation ENABLE ROW LEVEL SECURITY;

CREATE POLICY notification_invitation_all ON vibetype.notification_invitation FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

CREATE POLICY notification_invitation_insert ON vibetype.notification_invitation FOR INSERT
WITH CHECK (
  vibetype.invoker_account_id() = (
    SELECT e.created_by
    FROM vibetype.guest g
      JOIN vibetype.event e ON g.event_id = e.id
    WHERE g.id = guest_id
  )
);

COMMIT;
