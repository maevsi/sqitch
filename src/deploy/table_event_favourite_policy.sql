BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_favourite TO maevsi_account;

ALTER TABLE maevsi.event_favourite ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current user.
CREATE POLICY event_favourite_select ON maevsi.event_favourite FOR SELECT USING (
  maevsi.invoker_account_id() IS NOT NULL
  AND
  account_id = maevsi.invoker_account_id()
);

COMMIT;
