BEGIN;

CREATE TABLE vibetype.event_recommendation (
  account_id uuid NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  score float(8),
  predicted_score float(8),

  PRIMARY KEY (account_id, event_id)
);

COMMENT ON TABLE vibetype.event_recommendation IS 'Events recommended to a user account (M:N relationship).';
COMMENT ON COLUMN vibetype.event_recommendation.account_id IS 'A user account id.';
COMMENT ON COLUMN vibetype.event_recommendation.event_id IS 'An event id.';
COMMENT ON COLUMN vibetype.event_recommendation.score IS 'An event id.';
COMMENT ON COLUMN vibetype.event_recommendation.predicted_score IS 'The score of the recommendation.';
COMMENT ON COLUMN vibetype.event_recommendation.event_id IS 'The predicted score of the recommendation.';

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.event_recommendation TO vibetype_account;

ALTER TABLE vibetype.event_recommendation ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_recommendation_select ON vibetype.event_recommendation FOR SELECT USING (
  account_id = vibetype.invoker_account_id()
);

COMMIT;
