\echo test_outbox_payload...

BEGIN;

-- Test that an email address verification request's outbox payload only encrypts the address and
-- the verification code, leaving the non-PII expiry timestamp as plaintext for analytics.
SAVEPOINT outbox_payload_email_address_verification;
DO $$
DECLARE
  outbox_row RECORD;
  subject_key BYTEA;
  subject_id UUID;
  encrypted_bytes BYTEA;
  decrypted JSONB;
BEGIN
  PERFORM vibetype.email_address_verification_request('verify@example.com', 'en', 'Europe/Berlin');

  SELECT o.id, o.aggregate_id, o.payload INTO outbox_row
    FROM vibetype_private.outbox o
    WHERE o.type = 'email_address.verification_requested'
      AND o.aggregate_id = (SELECT id FROM vibetype_private.email_address WHERE address = 'verify@example.com');

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): no outbox event found';
  END IF;

  IF outbox_row.payload ? 'emailAddress' OR outbox_row.payload ? 'code' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): payload must not carry plaintext PII or credentials';
  END IF;

  IF NOT (outbox_row.payload ? 'valid_until') THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): payload must carry the non-PII valid_until as plaintext';
  END IF;

  SELECT s.id, s.key INTO subject_id, subject_key
    FROM vibetype_private.email_address ea
    JOIN vibetype_private.subject s ON s.id = ea.subject_id
    WHERE ea.address = 'verify@example.com';

  IF subject_key IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): could not resolve subject key';
  END IF;

  IF outbox_row.payload ->> 'subject_id' != subject_id::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): payload subject_id % does not match %', outbox_row.payload ->> 'subject_id', subject_id;
  END IF;

  encrypted_bytes := decode(outbox_row.payload ->> 'encrypted', 'base64');
  decrypted := convert_from(
    public.decrypt_iv(substring(encrypted_bytes FROM 17), subject_key, substring(encrypted_bytes FROM 1 FOR 16), 'aes'),
    'UTF8'
  )::jsonb;

  IF decrypted ->> 'emailAddress' != 'verify@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): decrypted emailAddress % does not match', decrypted ->> 'emailAddress';
  END IF;

  IF decrypted ->> 'code' IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_email_address_verification): decrypted code must not be null';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_payload_email_address_verification;

-- Test that a password reset request's outbox payload only encrypts PII and the credential
-- itself, leaving the non-PII expiry timestamp as plaintext for analytics.
SAVEPOINT outbox_payload_account_password_reset;
DO $$
DECLARE
  accountA UUID;
  outbox_row RECORD;
  subject_key BYTEA;
  subject_id UUID;
  encrypted_bytes BYTEA;
  decrypted JSONB;
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

  IF outbox_row.payload ? 'emailAddress' OR outbox_row.payload ? 'passwordResetVerification' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload must not carry plaintext PII or credentials';
  END IF;

  IF NOT (outbox_row.payload ? 'password_reset_verification_valid_until') THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload must carry the non-PII password_reset_verification_valid_until as plaintext';
  END IF;

  IF outbox_row.payload ->> 'account_id' != accountA::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload account_id % does not match %', outbox_row.payload ->> 'account_id', accountA;
  END IF;

  SELECT s.id, s.key INTO subject_id, subject_key
    FROM vibetype_private.account_email_address aea
    JOIN vibetype_private.email_address ea ON ea.id = aea.email_address_id
    JOIN vibetype_private.subject s ON s.id = ea.subject_id
    WHERE aea.account_id = accountA AND aea.is_primary;

  IF subject_key IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): could not resolve subject key';
  END IF;

  IF outbox_row.payload ->> 'subject_id' != subject_id::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): payload subject_id % does not match %', outbox_row.payload ->> 'subject_id', subject_id;
  END IF;

  encrypted_bytes := decode(outbox_row.payload ->> 'encrypted', 'base64');
  decrypted := convert_from(
    public.decrypt_iv(substring(encrypted_bytes FROM 17), subject_key, substring(encrypted_bytes FROM 1 FOR 16), 'aes'),
    'UTF8'
  )::jsonb;

  IF decrypted ->> 'emailAddress' != 'a@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): decrypted emailAddress % does not match', decrypted ->> 'emailAddress';
  END IF;

  IF decrypted ->> 'passwordResetVerification' IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_account_password_reset): decrypted passwordResetVerification must not be null';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_payload_account_password_reset;

-- Test that a guest invitation's outbox payload only encrypts the contact's email address and the
-- event creator's identifying fields (username, profile picture), leaving the event's own
-- business data (not PII of the invitee) as plaintext for analytics.
SAVEPOINT outbox_payload_guest_invitation;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  outbox_row RECORD;
  subject_key BYTEA;
  subject_id UUID;
  encrypted_bytes BYTEA;
  decrypted JSONB;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Test Event', 'test-event', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.contact SET time_zone = 'Europe/Berlin' WHERE id = contactAB;
  PERFORM vibetype.invite(guestAB, 'de');
  PERFORM vibetype_test.invoker_set_previous();

  SELECT id, aggregate_id, payload INTO outbox_row
    FROM vibetype_private.outbox
    WHERE type = 'guest.invited'
      AND aggregate_id = guestAB;

  IF outbox_row IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): no outbox event found';
  END IF;

  IF outbox_row.payload ? 'contactEmailAddress' OR outbox_row.payload ? 'eventCreatorUsername' OR outbox_row.payload ? 'eventCreatorProfilePictureUploadStorageKey' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload must not carry plaintext PII';
  END IF;

  IF NOT (outbox_row.payload ? 'contact_time_zone' AND outbox_row.payload ? 'event') THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload must carry the non-PII contact_time_zone and event data as plaintext';
  END IF;

  IF outbox_row.payload -> 'event' ->> 'name' != 'Test Event' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): plaintext event name % does not match', outbox_row.payload -> 'event' ->> 'name';
  END IF;

  IF outbox_row.payload ->> 'guest_id' != guestAB::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload guest_id % does not match %', outbox_row.payload ->> 'guest_id', guestAB;
  END IF;

  -- template must carry time_zone alongside language, consistent with account_registration,
  -- account_password_reset_request, and email_address_verification_request's own template objects.
  IF outbox_row.payload -> 'template' ->> 'time_zone' != 'Europe/Berlin' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): template time_zone % does not match', outbox_row.payload -> 'template' ->> 'time_zone';
  END IF;

  SELECT s.id, s.key INTO subject_id, subject_key
    FROM vibetype.contact_email_address cea
    JOIN vibetype_private.email_address ea ON ea.id = cea.email_address_id
    JOIN vibetype_private.subject s ON s.id = ea.subject_id
    WHERE cea.contact_id = contactAB AND cea.is_primary;

  IF subject_key IS NULL THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): could not resolve subject key';
  END IF;

  IF outbox_row.payload ->> 'subject_id' != subject_id::text THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): payload subject_id % does not match %', outbox_row.payload ->> 'subject_id', subject_id;
  END IF;

  encrypted_bytes := decode(outbox_row.payload ->> 'encrypted', 'base64');
  decrypted := convert_from(
    public.decrypt_iv(substring(encrypted_bytes FROM 17), subject_key, substring(encrypted_bytes FROM 1 FOR 16), 'aes'),
    'UTF8'
  )::jsonb;

  IF decrypted ->> 'contactEmailAddress' != 'b@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): decrypted contactEmailAddress % does not match', decrypted ->> 'contactEmailAddress';
  END IF;

  IF decrypted ->> 'eventCreatorUsername' != 'a' THEN
    RAISE EXCEPTION 'Test failed (outbox_payload_guest_invitation): decrypted eventCreatorUsername % does not match', decrypted ->> 'eventCreatorUsername';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_payload_guest_invitation;

ROLLBACK;
