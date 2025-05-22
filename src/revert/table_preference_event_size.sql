BEGIN;

DROP POLICY preference_event_size_all ON vibetype.preference_event_size;

DROP TABLE vibetype.preference_event_size;

COMMIT;
