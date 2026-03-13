BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

DROP ROLE :"role_service_grafana_username";

COMMIT;
