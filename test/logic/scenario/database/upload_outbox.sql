\echo test_upload_outbox...

BEGIN;

-- Test that deleting an upload publishes an outbox event carrying its storage key
SAVEPOINT upload_outbox_delete;
DO $$
DECLARE
  accountA UUID;
  uploadA UUID;
  outbox_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.upload (created_by, size_byte, storage_key)
    VALUES (accountA, 1024, 'test-storage-key')
    RETURNING id INTO uploadA;

  DELETE FROM vibetype.upload WHERE id = uploadA;

  PERFORM vibetype_test.invoker_set_previous();

  SELECT count(*) INTO outbox_count
    FROM vibetype_private.outbox
    WHERE channel = 'upload'
      AND payload = jsonb_build_object('id', uploadA, 'op', 'd', 'storage_key', 'test-storage-key');

  IF outbox_count != 1 THEN
    RAISE EXCEPTION 'Test failed (upload_outbox_delete): expected 1 outbox event, got %', outbox_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT upload_outbox_delete;

-- Test that creating an upload does not publish an outbox event
SAVEPOINT upload_outbox_insert;
DO $$
DECLARE
  accountA UUID;
  uploadA UUID;
  outbox_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.upload (created_by, size_byte, storage_key)
    VALUES (accountA, 1024, 'test-storage-key')
    RETURNING id INTO uploadA;

  PERFORM vibetype_test.invoker_set_previous();

  SELECT count(*) INTO outbox_count
    FROM vibetype_private.outbox
    WHERE channel = 'upload'
      AND payload ->> 'id' = uploadA::text;

  IF outbox_count != 0 THEN
    RAISE EXCEPTION 'Test failed (upload_outbox_insert): expected 0 outbox events, got %', outbox_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT upload_outbox_insert;

ROLLBACK;
