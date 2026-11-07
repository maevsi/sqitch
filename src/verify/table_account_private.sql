BEGIN;

SELECT id,
       birth_date,
       email_address,
       email_address_verification,
       email_address_verification_valid_until,
       password_hash,
       password_reset_verification,
       password_reset_verification_valid_until,
       upload_quota_bytes,
       created_at,
       last_activity
FROM vibetype_private.account WHERE FALSE;


\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
SET local role.grafana_username TO :'role_service_grafana_username';
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_account', 'vibetype_private.account', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('vibetype_anonymous', 'vibetype_private.account', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege(current_setting('role.vibetype_username'), 'vibetype_private.account', 'DELETE'));

  ASSERT NOT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.account', 'password_hash', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.account', 'email_address_verification', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.account', 'password_reset_verification', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.account', 'created_at', 'SELECT'));

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_email_address_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.trigger_account_email_address_verification_valid_until()', 'EXECUTE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_password_reset_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.trigger_account_password_reset_verification_valid_until()', 'EXECUTE'));
END $$;

ROLLBACK;
