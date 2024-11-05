-- Deploy maevsi:table_event_recommendation_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_recommendation TO maevsi_account;

ALTER TABLE maevsi.event_recommendation ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current user.
CREATE POLICY event_recommendation_select ON maevsi.event_recommendation FOR SELECT USING (
  NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID IS NOT NULL
  AND
  account_id = NULLIF(current_setting('jwt.claims.account_id', true), '')::UUID
);

-- TODO: policies for background process updating the recommendations

COMMIT;
