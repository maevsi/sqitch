BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`
SET LOCAL role.reccoom_username TO :'role_service_reccoom_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.guest', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.contact', 'SELECT'));
END $$;

ROLLBACK;
