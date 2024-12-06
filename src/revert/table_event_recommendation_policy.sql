-- Revert maevsi:table_event_recommendation_policy from pg

BEGIN;

DROP POLICY event_recommendation_select ON maevsi.event_recommendation;

COMMIT;
