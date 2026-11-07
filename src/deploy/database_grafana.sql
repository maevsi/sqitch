\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

SELECT 'CREATE DATABASE grafana OWNER "' || :'role_service_grafana_username' || '";'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'grafana'
)\gexec

ALTER DATABASE grafana OWNER TO :"role_service_grafana_username";

COMMENT ON DATABASE grafana IS 'The observation dashboard''s database.';
