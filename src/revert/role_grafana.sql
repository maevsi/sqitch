\connect grafana

BEGIN;

\set role_grafana_username `cat /run/secrets/postgres_role_grafana_username`

DROP OWNED BY :role_grafana_username;
DROP ROLE :role_grafana_username;

COMMIT;
