BEGIN;

SELECT id,
       location,
       radius,
       created_at,
       created_by
FROM vibetype.account_preference_event_location WHERE FALSE;

\set role_service_vibetype_username `cat /run/secrets/postgres_role_service_vibetype_username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_preference_event_location', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_preference_event_location', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_preference_event_location', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.account_preference_event_location', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_preference_event_location', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_preference_event_location', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_preference_event_location', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.account_preference_event_location', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.account_preference_event_location', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.account_preference_event_location', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.account_preference_event_location', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.account_preference_event_location', 'DELETE'));
END $$;

ROLLBACK;
