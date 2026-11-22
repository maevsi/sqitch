BEGIN;

DROP POLICY device_service_vibetype_delete ON vibetype.device;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

REVOKE DELETE ON TABLE vibetype.device FROM :role_service_vibetype_username;

DROP FUNCTION vibetype_private.outbox_account_notification_resolve(UUID);

DROP TRIGGER outbox ON vibetype.account_notification;
DROP FUNCTION vibetype_private.trigger_account_notification_outbox();

COMMIT;
