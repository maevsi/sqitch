BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres_role_service_grafana_username`

DROP ROLE :role_service_grafana_username;

COMMIT;
