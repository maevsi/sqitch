BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_recommendation TO vibetype_account;

ALTER TABLE vibetype.event_recommendation ENABLE ROW LEVEL SECURITY;

-- Only allow selects by the current user.
CREATE POLICY event_recommendation_select ON vibetype.event_recommendation FOR SELECT USING (
  vibetype.invoker_account_id() IS NOT NULL
  AND
  account_id = vibetype.invoker_account_id()
);

COMMIT;
