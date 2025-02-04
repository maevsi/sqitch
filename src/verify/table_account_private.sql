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

-- TODO: extract to helper function
WITH expected_indexes AS (
    SELECT unnest(ARRAY['idx_account_private_location']) AS indexname
),
existing_indexes AS (
    SELECT indexname FROM pg_indexes
    WHERE schemaname = 'maevsi_private'
    AND indexname IN (SELECT indexname FROM expected_indexes)
)
SELECT 1 / NULLIF(
    0,
    (SELECT COUNT(*) FROM existing_indexes) -
    (SELECT COUNT(*) FROM expected_indexes)
) AS status;

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
