BEGIN;

SELECT id,
       account_id,
       upload_id
FROM maevsi.profile_picture WHERE FALSE;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`
SET local role.maevsi_tusd_username TO :'role_maevsi_tusd_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.profile_picture', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.profile_picture', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.profile_picture', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi.profile_picture', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.profile_picture', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.profile_picture', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.profile_picture', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi.profile_picture', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.profile_picture', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.profile_picture', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.profile_picture', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.maevsi_tusd_username'), 'maevsi.profile_picture', 'DELETE'));
END $$;

ROLLBACK;
