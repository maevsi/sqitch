BEGIN;

DROP POLICY account_preference_event_category_all ON vibetype.account_preference_event_category;

DROP TABLE vibetype.account_preference_event_category;

COMMIT;
