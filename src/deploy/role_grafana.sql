BEGIN;

\set role_service_grafana_password `cat /run/secrets/postgres-role-service-grafana-password`
\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

DROP ROLE IF EXISTS :"role_service_grafana_username";
CREATE ROLE :"role_service_grafana_username" LOGIN PASSWORD :'role_service_grafana_password';

COMMIT;
