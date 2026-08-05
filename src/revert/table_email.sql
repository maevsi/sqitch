BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

DROP TRIGGER update ON vibetype_private.email;
DROP POLICY email_service_vibetype_all ON vibetype_private.email;
REVOKE USAGE ON SCHEMA vibetype_private FROM :role_service_vibetype_username; -- TODO: move to schema in next major
REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE vibetype_private.email FROM :role_service_vibetype_username;
DROP INDEX vibetype_private.idx_email_updated_by;
DROP TABLE vibetype_private.email;
DROP TYPE vibetype_private.email_status;

COMMIT;
