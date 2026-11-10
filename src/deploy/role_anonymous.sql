BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`

DO $$
BEGIN
  IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'vibetype_anonymous') THEN
    CREATE ROLE vibetype_anonymous;
  END IF;
END $$;

GRANT vibetype_anonymous to :role_service_postgraphile_username;

COMMIT;
