BEGIN;

DROP POLICY notification_all ON vibetype.notification;

DROP TABLE vibetype.notification;

COMMIT;
