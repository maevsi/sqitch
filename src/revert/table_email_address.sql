BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`

DROP POLICY email_address_service_vibetype_all ON vibetype_private.email_address;
DROP TRIGGER update ON vibetype_private.email_address;
DROP INDEX vibetype_private.idx_email_address_updated_by;
REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLE vibetype_private.email_address FROM :role_service_vibetype_username;
REVOKE USAGE ON SCHEMA vibetype_private FROM :role_service_vibetype_username; -- TODO: move to schema in next major
DROP TABLE vibetype_private.email_address;
DROP TYPE vibetype_private.email_address_status;

COMMIT;
