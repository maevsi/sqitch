BEGIN;

\set role_service_grafana_password `cat /run/secrets/postgres_role_service_grafana_password`
\set role_service_grafana_username `cat /run/secrets/postgres_role_service_grafana_username`

DROP ROLE IF EXISTS :role_service_grafana_username;
CREATE ROLE :role_service_grafana_username LOGIN PASSWORD :'role_service_grafana_password';

COMMIT;
