BEGIN;

SELECT id,
       description,
       is_archived,
       name,
       slug,
       created_at,
       created_by
FROM maevsi.event_group WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['event_group_created_by_slug_key']
);

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
SET local role.maevsi_tusd_username TO :'role_maevsi_tusd_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.event_group', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.event_group', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.event_group', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.event_group', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.event_group', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.event_group', 'DELETE'));
END $$;

ROLLBACK;
