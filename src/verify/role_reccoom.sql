BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

SET LOCAL role.service_reccoom_username TO :'role_service_reccoom_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.service_reccoom_username'), 'USAGE'));
END $$;

ROLLBACK;
