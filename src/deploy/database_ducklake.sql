\set role_service_gizmosql_username `cat /run/secrets/postgres-role-service-gizmosql-username`

SELECT 'CREATE DATABASE ducklake OWNER "' || :'role_service_gizmosql_username' || '";'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'ducklake'
)\gexec

ALTER DATABASE ducklake OWNER TO :"role_service_gizmosql_username";

COMMENT ON DATABASE ducklake IS 'The analytics lakehouse catalog database.';
