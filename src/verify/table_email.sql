BEGIN;

SELECT id,
       address,
       address_hash,
       status,
       reason,
       created_at,
       updated_at,
       updated_by
FROM vibetype_private.email WHERE FALSE;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.email', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.email', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.email', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.email', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.email', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.email', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.email', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.email', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.email', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.email', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.email', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.email', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_schema_privilege(current_setting('role.vibetype_username'), 'vibetype_private', 'USAGE')); -- TODO: move to schema in next major
END $$;

ROLLBACK;
