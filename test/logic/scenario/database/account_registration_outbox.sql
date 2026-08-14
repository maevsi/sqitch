\echo test_account_registration_outbox...

BEGIN;

-- Test that registering an account publishes an outbox event whose aggregate_id is the
-- account's id, and whose payload carries the outbox event's own id (needed since the
-- Kafka message key is now the aggregate_id, not the outbox event's id).
SAVEPOINT account_registration_outbox;
DO $$
DECLARE
  accountA UUID;
  outbox_row RECORD;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  SELECT id, aggregate_id, payload INTO outbox_row
    FROM vibetype_private.outbox
    WHERE channel = 'account_registration'
      AND aggregate_id = accountA;

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): no outbox event found for account %', accountA;
  END IF;

  IF outbox_row.payload ->> 'id' != outbox_row.id::text THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload id % does not match outbox event id %', outbox_row.payload ->> 'id', outbox_row.id;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_registration_outbox;

ROLLBACK;
