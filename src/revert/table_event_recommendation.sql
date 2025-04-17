BEGIN;

DROP POLICY event_recommendation_select ON vibetype.event_recommendation;

DROP TABLE vibetype.event_recommendation;

COMMIT;
