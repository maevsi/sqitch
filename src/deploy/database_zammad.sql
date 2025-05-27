\set role_service_zammad_username `cat /run/secrets/postgres_role_service_zammad_username`

SELECT 'CREATE DATABASE zammad OWNER "' || :'role_service_zammad_username' || '";'
WHERE NOT EXISTS (
  SELECT FROM pg_database WHERE datname = 'zammad'
)\gexec

COMMENT ON DATABASE zammad IS 'The customer service database.';
