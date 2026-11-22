BEGIN;

DROP FUNCTION vibetype.notification_acknowledge(UUID, BOOLEAN);
DROP TABLE vibetype_private.notification;

COMMIT;
