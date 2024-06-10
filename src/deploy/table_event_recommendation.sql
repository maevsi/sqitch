-- Deploy maevsi:table_event_recommendation to pg

BEGIN;

CREATE TABLE maevsi.event_recommendation (
  user_id uuid NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES maevsi.event(id) ON DELETE CASCADE,
  score float(8),
  predicted_score float(8),
  PRIMARY KEY (user_id, event_id)
);

COMMIT;
