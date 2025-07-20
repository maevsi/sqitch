BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

DELETE FROM vibetype.device;
ALTER TABLE vibetype.device
  ALTER COLUMN fcm_token
  SET NOT NULL;

GRANT SELECT ON TABLE vibetype.device TO :role_service_vibetype_username;

CREATE POLICY device_service_vibetype_select ON vibetype.device FOR SELECT
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
