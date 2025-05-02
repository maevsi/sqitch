BEGIN;

DROP POLICY account_preference_event_size_all ON vibetype.account_preference_event_size;

DROP TABLE vibetype.account_preference_event_size;

COMMIT;
