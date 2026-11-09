BEGIN;

SELECT id,
       account_id,
       upload_id
FROM vibetype.profile_picture WHERE FALSE;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.profile_picture', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.profile_picture', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.profile_picture', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.profile_picture', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.profile_picture', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.profile_picture', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.profile_picture', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.profile_picture', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.profile_picture', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.profile_picture', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.profile_picture', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.profile_picture', 'DELETE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.upload_is_own(UUID)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.upload_is_own(UUID)', 'EXECUTE'));
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'profile_picture' AND policyname = 'profile_picture_upload_own' AND permissive = 'RESTRICTIVE');
END $$;

ROLLBACK;
