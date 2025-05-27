BEGIN;

DROP POLICY preference_event_location_all ON vibetype.preference_event_location;

DROP TABLE vibetype.preference_event_location;

COMMIT;
