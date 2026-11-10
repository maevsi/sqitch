\echo test_outbox...

BEGIN;

SAVEPOINT outbox_delete_after_insert;
DO $$
DECLARE
  _aggregate_id UUID := gen_random_uuid();
BEGIN
  PERFORM vibetype_private.outbox_insert('account', _aggregate_id, 'account.deleted', jsonb_build_object('account_id', _aggregate_id));

  IF EXISTS (SELECT 1 FROM vibetype_private.outbox WHERE aggregate_id = _aggregate_id) THEN
    RAISE EXCEPTION 'Test failed (outbox_delete_after_insert): outbox row was not deleted after its insertion';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_delete_after_insert;

SAVEPOINT outbox_envelope;
DO $$
DECLARE
  _account_id UUID;
  _outbox vibetype_private.outbox;
BEGIN
  _account_id := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.outbox_capture();
  PERFORM vibetype.account_password_reset_request('a@example.com', 'de', 'Europe/Berlin');

  SELECT * INTO _outbox FROM vibetype_private.outbox WHERE type = 'account.password_reset_requested';

  IF _outbox.aggregate_type IS DISTINCT FROM 'account' OR _outbox.aggregate_id IS DISTINCT FROM _account_id THEN
    RAISE EXCEPTION 'Test failed (outbox_envelope): unexpected aggregate %/%', _outbox.aggregate_type, _outbox.aggregate_id;
  END IF;

  IF _outbox.payload IS DISTINCT FROM jsonb_build_object(
    'id', _outbox.id,
    'type', 'account.password_reset_requested',
    'aggregate_type', 'account',
    'aggregate_id', _account_id,
    'version', 1,
    'occurred_at', _outbox.created_at,
    'data', jsonb_build_object('account_id', _account_id, 'language', 'de')
  ) THEN
    RAISE EXCEPTION 'Test failed (outbox_envelope): unexpected payload %', _outbox.payload;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_envelope;

SAVEPOINT outbox_account_deleted;
DO $$
DECLARE
  _account_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.outbox_capture();
  PERFORM vibetype_test.invoker_set(_account_id);
  PERFORM vibetype.account_delete('password');
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.outbox_payload('account.deleted', _account_id) -> 'data' IS DISTINCT FROM jsonb_build_object('account_id', _account_id) THEN
    RAISE EXCEPTION 'Test failed (outbox_account_deleted): unexpected data';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_account_deleted;

SAVEPOINT outbox_event;
DO $$
DECLARE
  _account_id UUID;
  _event_id UUID;
  _snapshot JSONB;
BEGIN
  _account_id := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.outbox_capture();

  _event_id := vibetype_test.event_create(_account_id, 'Event', 'event', '2025-06-01 20:00', 'public');
  SELECT to_jsonb(e) INTO _snapshot FROM vibetype.event e WHERE id = _event_id;

  IF vibetype_test.outbox_payload('event.created', _event_id) -> 'data' IS DISTINCT FROM _snapshot THEN
    RAISE EXCEPTION 'Test failed (outbox_event): unexpected event.created data';
  END IF;

  PERFORM vibetype_test.invoker_set(_account_id);
  UPDATE vibetype.event SET name = 'Event updated' WHERE id = _event_id;
  PERFORM vibetype_test.invoker_set_previous();
  SELECT to_jsonb(e) INTO _snapshot FROM vibetype.event e WHERE id = _event_id;

  IF vibetype_test.outbox_payload('event.updated', _event_id) -> 'data' IS DISTINCT FROM _snapshot THEN
    RAISE EXCEPTION 'Test failed (outbox_event): unexpected event.updated data';
  END IF;

  PERFORM vibetype_test.invoker_set(_account_id);
  DELETE FROM vibetype.event WHERE id = _event_id;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.outbox_payload('event.deleted', _event_id) -> 'data' IS DISTINCT FROM _snapshot THEN
    RAISE EXCEPTION 'Test failed (outbox_event): unexpected event.deleted data';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_event;

SAVEPOINT outbox_upload_deleted;
DO $$
DECLARE
  _account_id UUID;
  _upload_id UUID;
BEGIN
  _account_id := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.outbox_capture();
  PERFORM vibetype_test.invoker_set(_account_id);

  INSERT INTO vibetype.upload (created_by, size_byte, storage_key)
    VALUES (_account_id, 1024, 'storage-key')
    RETURNING id INTO _upload_id;

  DELETE FROM vibetype.upload WHERE id = _upload_id;

  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT count(*) FROM vibetype_private.outbox WHERE aggregate_id = _upload_id) != 1 THEN
    RAISE EXCEPTION 'Test failed (outbox_upload_deleted): expected only the deletion as outbox event';
  END IF;

  IF vibetype_test.outbox_payload('upload.deleted', _upload_id) -> 'data' ->> 'storage_key' IS DISTINCT FROM 'storage-key' THEN
    RAISE EXCEPTION 'Test failed (outbox_upload_deleted): data lacks the storage key';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_upload_deleted;

SAVEPOINT outbox_processed;
DO $$
DECLARE
  _outbox_id UUID := gen_random_uuid();
BEGIN
  IF vibetype.outbox_is_processed(_outbox_id) THEN
    RAISE EXCEPTION 'Test failed (outbox_processed): unmarked event is processed';
  END IF;

  PERFORM vibetype.outbox_mark_processed(_outbox_id);
  PERFORM vibetype.outbox_mark_processed(_outbox_id);

  IF NOT vibetype.outbox_is_processed(_outbox_id) THEN
    RAISE EXCEPTION 'Test failed (outbox_processed): marked event is not processed';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_processed;

SAVEPOINT outbox_account_resolve;
DO $$
DECLARE
  _account_id UUID;
  _resolved RECORD;
BEGIN
  _account_id := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype.account_password_reset_request('a@example.com', 'en');

  SELECT * INTO _resolved FROM vibetype_private.outbox_account_resolve(_account_id);

  IF _resolved.username IS DISTINCT FROM 'a'
    OR _resolved.email_address IS DISTINCT FROM 'a@example.com'
    OR _resolved.password_reset_verification IS DISTINCT FROM vibetype_test.account_password_reset_verification_get('a@example.com')
  THEN
    RAISE EXCEPTION 'Test failed (outbox_account_resolve): unexpected account %', _resolved;
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.outbox_account_resolve(gen_random_uuid())) THEN
    RAISE EXCEPTION 'Test failed (outbox_account_resolve): resolved a missing account';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_account_resolve;

SAVEPOINT outbox_guest_invitation_resolve;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _contact_ab UUID;
  _contact_ac UUID;
  _event_id UUID;
  _guest_ab UUID;
  _guest_ac UUID;
  _resolved RECORD;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _contact_ab := vibetype_test.contact_create(_account_a, 'b@example.com');
  _contact_ac := vibetype_test.contact_create(_account_a, 'c@example.com');
  _event_id := vibetype_test.event_create(_account_a, 'Event', 'event', '2025-06-01 20:00', 'public');
  _guest_ab := vibetype_test.guest_create(_account_a, _event_id, _contact_ab);
  _guest_ac := vibetype_test.guest_create(_account_a, _event_id, _contact_ac);

  UPDATE vibetype_private.account SET email_address = 'b-account@example.com' WHERE id = _account_b;

  SELECT * INTO _resolved FROM vibetype_private.outbox_guest_invitation_resolve(_guest_ab);

  IF _resolved.contact_email_address IS DISTINCT FROM 'b-account@example.com'
    OR _resolved.event ->> 'name' IS DISTINCT FROM 'Event'
    OR _resolved.event_creator_username IS DISTINCT FROM 'a'
  THEN
    RAISE EXCEPTION 'Test failed (outbox_guest_invitation_resolve): unexpected invitation %', _resolved;
  END IF;

  SELECT * INTO _resolved FROM vibetype_private.outbox_guest_invitation_resolve(_guest_ac);

  IF _resolved.contact_email_address IS DISTINCT FROM 'c@example.com' THEN
    RAISE EXCEPTION 'Test failed (outbox_guest_invitation_resolve): expected the contact''s own email address, got %', _resolved.contact_email_address;
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype_private.outbox_guest_invitation_resolve(gen_random_uuid())) THEN
    RAISE EXCEPTION 'Test failed (outbox_guest_invitation_resolve): resolved a missing guest';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT outbox_guest_invitation_resolve;

ROLLBACK;
