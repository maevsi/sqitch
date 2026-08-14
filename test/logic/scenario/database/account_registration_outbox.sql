\echo test_account_registration_outbox...

BEGIN;

-- Test that registering an account publishes an outbox event whose aggregate_type/aggregate_id
-- are 'account'/the account's id, and whose payload carries the outbox event's own id and type
-- (needed since the Kafka topic is now shared with account_password_reset_request and keyed by
-- aggregate_id, not the outbox event's own id).
SAVEPOINT account_registration_outbox;
DO $$
DECLARE
  accountA UUID;
  outbox_row RECORD;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  SELECT id, aggregate_type, aggregate_id, type, payload INTO outbox_row
    FROM vibetype_private.outbox
    WHERE type = 'account_registration'
      AND aggregate_id = accountA;

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): no outbox event found for account %', accountA;
  END IF;

  IF outbox_row.aggregate_type != 'account' THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): expected aggregate_type account, got %', outbox_row.aggregate_type;
  END IF;

  IF outbox_row.payload ->> 'id' != outbox_row.id::text THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload id % does not match outbox event id %', outbox_row.payload ->> 'id', outbox_row.id;
  END IF;

  IF outbox_row.payload ->> 'type' != outbox_row.type THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload type % does not match outbox event type %', outbox_row.payload ->> 'type', outbox_row.type;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_registration_outbox;

ROLLBACK;
