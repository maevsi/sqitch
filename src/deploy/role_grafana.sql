\connect grafana

BEGIN;

\set role_grafana_password `cat /run/secrets/postgres_role_grafana_password`
\set role_grafana_username `cat /run/secrets/postgres_role_grafana_username`

DROP ROLE IF EXISTS :role_grafana_username;
CREATE ROLE :role_grafana_username LOGIN PASSWORD :'role_grafana_password';

GRANT ALL PRIVILEGES ON DATABASE grafana TO :role_grafana_username;
GRANT ALL ON SCHEMA public TO :role_grafana_username;

COMMIT;
