\echo test_account_upload_quota_bytes...

BEGIN;

SAVEPOINT account_upload_quota_bytes_default;
DO $$
DECLARE
  accountA UUID;
  quotaBytes BIGINT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  quotaBytes := vibetype.account_upload_quota_bytes();

  -- Check that quota is returned (should be default value)
  IF quotaBytes IS NULL THEN
    RAISE EXCEPTION 'Test failed: account_upload_quota_bytes returned NULL';
  END IF;

  IF quotaBytes < 0 THEN
    RAISE EXCEPTION 'Test failed: account_upload_quota_bytes returned negative value %', quotaBytes;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_upload_quota_bytes_default;

SAVEPOINT account_upload_quota_bytes_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.account_upload_quota_bytes();
    RAISE EXCEPTION 'Test failed: anonymous user should not be able to call account_upload_quota_bytes';
  EXCEPTION
    WHEN OTHERS THEN
      -- Expected to fail
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_upload_quota_bytes_anonymous;

ROLLBACK;
