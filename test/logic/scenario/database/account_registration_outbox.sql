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
    WHERE type = 'account.registered'
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

  IF outbox_row.payload ? 'account' THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload must not carry an "account" object';
  END IF;

  IF outbox_row.payload ->> 'account_id' != accountA::text THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload account_id % does not match %', outbox_row.payload ->> 'account_id', accountA;
  END IF;

  -- subject_id lets the consumer fetch the decryption key by a stable id instead of re-deriving
  -- "the current primary email" at consumption time.
  IF outbox_row.payload ->> 'subject_id' != (
    SELECT s.id::text
    FROM vibetype_private.account_email_address aea
    JOIN vibetype_private.email_address ea ON ea.id = aea.email_address_id
    JOIN vibetype_private.subject s ON s.id = ea.subject_id
    WHERE aea.account_id = accountA AND aea.is_primary
  ) THEN
    RAISE EXCEPTION 'Test failed (account_registration_outbox): payload subject_id % does not match the account''s primary email subject', outbox_row.payload ->> 'subject_id';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_registration_outbox;

ROLLBACK;
