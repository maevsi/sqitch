BEGIN;

DROP POLICY device_service_vibetype_select ON vibetype.device;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`
REVOKE SELECT ON TABLE vibetype.device FROM :role_service_vibetype_username;

ALTER TABLE vibetype.device
  ALTER COLUMN fcm_token
  DROP NOT NULL;

COMMIT;
