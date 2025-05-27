BEGIN;

DROP POLICY preference_event_category_all ON vibetype.preference_event_category;

DROP TABLE vibetype.preference_event_category;

COMMIT;
