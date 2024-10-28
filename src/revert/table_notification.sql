-- Revert maevsi:table_notification from pg

BEGIN;

DROP TABLE maevsi_private.notification;

COMMIT;
