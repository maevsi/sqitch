-- Deploy maevsi:table_event_recommendation to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: table_event

BEGIN;

CREATE TABLE maevsi.event_recommendation (
  account_id uuid NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES maevsi.event(id) ON DELETE CASCADE,
  score float(8),
  predicted_score float(8),

  PRIMARY KEY (account_id, event_id)
);

COMMENT ON TABLE maevsi.event_recommendation IS 'Events recommended to a user account (M:N relationship).';
COMMENT ON COLUMN maevsi.event_recommendation.account_id IS 'A user account id.';
COMMENT ON COLUMN maevsi.event_recommendation.event_id IS 'An event id.';
COMMENT ON COLUMN maevsi.event_recommendation.score IS 'An event id.';
COMMENT ON COLUMN maevsi.event_recommendation.predicted_score IS 'The score of the recommendation.';
COMMENT ON COLUMN maevsi.event_recommendation.event_id IS 'The predicted score of the recommendation.';

COMMIT;
