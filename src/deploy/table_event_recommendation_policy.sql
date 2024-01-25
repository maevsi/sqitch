-- Deploy maevsi:table_event_recommendation_policy to pg

BEGIN;

ALTER TABLE maevsi.event_recommendation ENABLE ROW LEVEL SECURITY;

COMMIT;
