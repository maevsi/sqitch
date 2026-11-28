BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`
SET local role.reccoom_username TO :'role_service_reccoom_username';
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.guest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.guest', 'INSERT'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'event_id', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'companion_count', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'companion_count_requested', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.guest', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype.guest', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.guest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.guest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.guest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype.guest', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.guest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.guest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.guest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype.guest', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.guest', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.guest', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.guest', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.reccoom_username'), 'vibetype.guest', 'DELETE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'feedback', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'feedback_override', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'feedback_reason', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'feedback', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'feedback_reason', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'feedback_override', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'companion_count', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'companion_count_requested', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'companion_count', 'UPDATE'));
  ASSERT (SELECT pg_catalog.has_column_privilege('vibetype_anonymous', 'vibetype.guest', 'companion_count_requested', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'contact_id', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege('vibetype_account', 'vibetype.guest', 'event_id', 'UPDATE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.trigger_guest_update()', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.trigger_guest_update()', 'EXECUTE'));
  ASSERT EXISTS (SELECT 1 FROM pg_catalog.pg_policies WHERE schemaname = 'vibetype' AND tablename = 'guest' AND policyname = 'guest_insert_join');
  ASSERT (SELECT 'vibetype_private.trigger_guest_feedback_deadline()'::regprocedure IS NOT NULL);
END $$;

ROLLBACK;
