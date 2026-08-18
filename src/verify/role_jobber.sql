BEGIN;

\set role_service_jobber_username `cat /run/secrets/postgres-role-service-jobber-username`

SET LOCAL role.service_jobber_username TO :'role_service_jobber_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_has_role(current_setting('role.service_jobber_username'), 'USAGE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.service_jobber_username'), 'vibetype_private.outbox', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.service_jobber_username'), 'vibetype_private.outbox', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.service_jobber_username'), 'vibetype_private.outbox', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.service_jobber_username'), 'vibetype_private.outbox', 'UPDATE'));
END $$;

ROLLBACK;
