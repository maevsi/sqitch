\echo test_upload_quota...

BEGIN;

-- An upload that would exceed the quota of its account is rejected, one that fills it exactly is not.
SAVEPOINT quota;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('username', 'email@example.com');

  UPDATE vibetype_private.account SET upload_quota_bytes = 10 WHERE id = _account_id;

  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_id, 6);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_id, 4);

  BEGIN
    INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_id, 1);
    RAISE EXCEPTION 'Test failed: an upload beyond the quota was accepted';
  EXCEPTION
    WHEN disk_full THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT quota;

ROLLBACK;
