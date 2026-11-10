BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vibetype_account') THEN
    CREATE ROLE vibetype_account;
  END IF;
END $$;

GRANT vibetype_account to :role_service_postgraphile_username;

COMMIT;
