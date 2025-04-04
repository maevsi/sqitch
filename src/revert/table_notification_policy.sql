BEGIN;

DROP POLICY notification_insert ON vibetype.notification;
DROP POLICY notification_select ON vibetype.notification;

COMMIT;