\echo test_outbox_payload...

BEGIN;

-- Test that a password reset request's outbox payload carries no PII, and that
-- outbox_payload_account() can fetch the account data needed to compose the email.
SAVEPOINT outbox_payload_account_password_reset;
DO $$
DECLARE
  accountA UUID;
  outbox_row RECORD;
  fetched RECORD;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype.account_password_reset_request('a@example.com', 'en', 'Europe/Berlin');

  SELECT id, aggregate_id, payload INTO outbox_row
    FROM vibetype_private.outbox
    WHERE type = 'account.password_reset_requested'
      AND aggregate_id = accountA;

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): no outbox event found';
  END IF;

  IF outbox_row.payload ? 'account' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload must not carry an "account" object';
  END IF;

  IF outbox_row.payload ->> 'account_id' != accountA::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload account_id % does not match %', outbox_row.payload ->> 'account_id', accountA;
  END IF;

  SELECT * INTO fetched FROM vibetype.outbox_payload_account(accountA);

  IF fetched.email_address != 'a@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): fetched email_address % does not match', fetched.email_address;
  END IF;

  IF fetched.username != 'a' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): fetched username % does not match', fetched.username;
  END IF;

  IF fetched.password_reset_verification IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): fetched password_reset_verification must not be null';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_payload_account_password_reset;

-- Test that a guest invitation's outbox payload carries no PII, and that
-- outbox_payload_guest_invitation() can fetch the data needed to compose the email.
SAVEPOINT outbox_payload_guest_invitation;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  outbox_row RECORD;
  fetched RECORD;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype.invite(guestAB, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  SELECT id, aggregate_id, payload INTO outbox_row
    FROM vibetype_private.outbox
    WHERE type = 'guest.invited'
      AND aggregate_id = guestAB;

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): no outbox event found';
  END IF;

  IF outbox_row.payload ? 'data' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload must not carry a "data" object';
  END IF;

  IF outbox_row.payload ->> 'guest_id' != guestAB::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload guest_id % does not match %', outbox_row.payload ->> 'guest_id', guestAB;
  END IF;

  SELECT * INTO fetched FROM vibetype.outbox_payload_guest_invitation(guestAB);

  IF fetched.contact_email_address != 'b@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): fetched contact_email_address % does not match', fetched.contact_email_address;
  END IF;

  IF fetched.event_creator_username != 'a' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): fetched event_creator_username % does not match', fetched.event_creator_username;
  END IF;

  IF fetched.event ->> 'name' != 'Test Event' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): fetched event name % does not match', fetched.event ->> 'name';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_payload_guest_invitation;

ROLLBACK;
