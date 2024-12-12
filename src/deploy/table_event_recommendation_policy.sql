BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_recommendation TO maevsi_account;

ALTER TABLE maevsi.event_recommendation ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current user.
CREATE POLICY event_recommendation_select ON maevsi.event_recommendation FOR SELECT USING (
  maevsi.account_id() IS NOT NULL
  AND
  account_id = maevsi.account_id()
);

COMMIT;
