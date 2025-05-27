BEGIN;

DROP POLICY account_preference_event_location_all ON vibetype.account_preference_event_location;

DROP TABLE vibetype.account_preference_event_location;

COMMIT;
