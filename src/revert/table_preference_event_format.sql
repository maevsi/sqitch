BEGIN;

DROP POLICY preference_event_format_all ON vibetype.preference_event_format;

DROP TABLE vibetype.preference_event_format;

COMMIT;
