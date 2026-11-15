BEGIN;

SELECT id,
       account_id,
       is_push_enabled,
       type,
       created_at
FROM vibetype.preference_notification WHERE FALSE;

ROLLBACK;

BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.preference_notification', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.preference_notification', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.preference_notification', 'is_push_enabled', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.preference_notification', 'type', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.preference_notification', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.preference_notification', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.preference_notification', 'INSERT'));
END $$;

ROLLBACK;
