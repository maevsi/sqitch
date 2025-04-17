BEGIN;

DROP POLICY account_preference_event_format_all ON vibetype.account_preference_event_format;

DROP TABLE vibetype.account_preference_event_format;

COMMIT;
