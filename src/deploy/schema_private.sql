BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

CREATE SCHEMA vibetype_private;

COMMENT ON SCHEMA vibetype_private IS 'Contains account information and is not used by PostGraphile.';

GRANT USAGE ON SCHEMA vibetype_private TO :"role_service_grafana_username";

COMMIT;
