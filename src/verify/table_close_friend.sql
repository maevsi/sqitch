BEGIN;

SELECT
  id,
  friendship_id,
  created_at,
  created_by
FROM vibetype.close_friend
WHERE FALSE;

ROLLBACK;

BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.close_friend', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.close_friend', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.close_friend', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.close_friend', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.close_friend', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.close_friend', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.close_friend', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.close_friend', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.close_friend', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.close_friend', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.close_friend', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.close_friend', 'DELETE'));
END $$;

ROLLBACK;
