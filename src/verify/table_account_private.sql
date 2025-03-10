BEGIN;

SELECT id,
       birth_date,
       email_address,
       email_address_verification,
       email_address_verification_valid_until,
       location,
       password_hash,
       password_reset_verification,
       password_reset_verification_valid_until,
       upload_quota_bytes,
       created_at,
       last_activity
FROM vibetype_private.account WHERE FALSE;

SELECT vibetype_test.index_existence(
  ARRAY ['idx_account_private_location'],
  'vibetype_private'
);

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`
SET local role.vibetype_username TO :'role_vibetype_username';

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

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.account_email_address_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.account_email_address_verification_valid_until()', 'EXECUTE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.account_password_reset_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.account_password_reset_verification_valid_until()', 'EXECUTE'));
END $$;

ROLLBACK;
