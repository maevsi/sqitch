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
FROM maevsi_private.account WHERE FALSE;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_account', 'maevsi_private.account', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_anonymous', 'maevsi_private.account', 'DELETE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.account', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.account', 'INSERT'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.account', 'UPDATE'));
  ASSERT NOT (SELECT pg_catalog.has_table_privilege('maevsi_tusd', 'maevsi_private.account', 'DELETE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi_private.account_email_address_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi_private.account_email_address_verification_valid_until()', 'EXECUTE'));

  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi_private.account_password_reset_verification_valid_until()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi_private.account_password_reset_verification_valid_until()', 'EXECUTE'));
END $$;

ROLLBACK;
