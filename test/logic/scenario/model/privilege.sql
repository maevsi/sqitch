\echo test_privilege...

BEGIN;

-- An account must not be able to delete or update the address of another account's event.
SAVEPOINT address_foreign_event_modification;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _address_a UUID;
  _event_a UUID;
  _row_count INTEGER;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _event_a := vibetype_test.event_create(_account_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(_account_a);
  INSERT INTO vibetype.address(name, created_by) VALUES ('Address by A', _account_a) RETURNING id INTO _address_a;
  UPDATE vibetype.event SET address_id = _address_a WHERE id = _event_a;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_b);

  IF NOT EXISTS (SELECT 1 FROM vibetype.address WHERE id = _address_a) THEN
    RAISE EXCEPTION 'Test failed: the address of a public event should be visible';
  END IF;

  UPDATE vibetype.address SET name = 'Updated', created_by = _account_b WHERE id = _address_a;
  GET DIAGNOSTICS _row_count = ROW_COUNT;

  IF _row_count > 0 THEN
    RAISE EXCEPTION 'Test failed: the address of another account''s event was updated';
  END IF;

  DELETE FROM vibetype.address WHERE id = _address_a;
  GET DIAGNOSTICS _row_count = ROW_COUNT;

  IF _row_count > 0 THEN
    RAISE EXCEPTION 'Test failed: the address of another account''s event was deleted';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT address_foreign_event_modification;

-- An account must not be able to use another account's upload as its profile picture.
SAVEPOINT profile_picture_foreign_upload;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _upload_a UUID;
  _upload_b UUID;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(_account_a);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_a, 1) RETURNING id INTO _upload_a;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_b);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_b, 1) RETURNING id INTO _upload_b;

  PERFORM vibetype.profile_picture_set(_upload_b);

  BEGIN
    PERFORM vibetype.profile_picture_set(_upload_a);
    RAISE EXCEPTION 'Test failed: another account''s upload was set as profile picture';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.profile_picture SET upload_id = _upload_a WHERE account_id = _account_b;
    RAISE EXCEPTION 'Test failed: the profile picture was updated to another account''s upload';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  IF EXISTS (SELECT 1 FROM vibetype.upload WHERE id = _upload_a) THEN
    RAISE EXCEPTION 'Test failed: another account''s upload is visible';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT profile_picture_foreign_upload;

-- An organizer must not be able to move a guest to another event or contact.
SAVEPOINT guest_update_event_contact;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _contact_a UUID;
  _contact_b UUID;
  _contact_b_self UUID;
  _event_a UUID;
  _event_b UUID;
  _guest_b UUID;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _event_a := vibetype_test.event_create(_account_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'private');
  _event_b := vibetype_test.event_create(_account_b, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'private');
  _contact_a := vibetype_test.contact_create(_account_a, 'contact-of-a@example.com');
  _contact_b := vibetype_test.contact_create(_account_b, 'contact-of-b@example.com');
  _contact_b_self := vibetype_test.contact_select_by_account_id(_account_b);
  _guest_b := vibetype_test.guest_create(_account_b, _event_b, _contact_b);

  PERFORM vibetype_test.invoker_set(_account_b);

  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = _guest_b;

  BEGIN
    UPDATE vibetype.guest SET event_id = _event_a, contact_id = _contact_b_self WHERE id = _guest_b;
    RAISE EXCEPTION 'Test failed: a guest was moved to another account''s event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    UPDATE vibetype.guest SET contact_id = _contact_a WHERE id = _guest_b;
    RAISE EXCEPTION 'Test failed: a guest was moved to another account''s contact';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.event_test('organizer cannot gain access to a foreign event via guest update', _account_b, ARRAY[_event_b]::UUID[]);
  PERFORM vibetype_test.contact_test('organizer cannot gain access to a foreign contact via guest update', _account_b, ARRAY[_contact_b, _contact_b_self]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT guest_update_event_contact;

-- The grafana role only has access to the metadata columns it needs.
SAVEPOINT grafana_columns;
DO $$
BEGIN
  IF has_column_privilege('grafana', 'vibetype_private.account', 'password_hash', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana can select account.password_hash';
  END IF;

  IF has_column_privilege('grafana', 'vibetype_private.account', 'email_address_verification', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana can select account.email_address_verification';
  END IF;

  IF has_column_privilege('grafana', 'vibetype_private.account', 'password_reset_verification', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana can select account.password_reset_verification';
  END IF;

  IF has_column_privilege('grafana', 'vibetype_private.notification', 'payload', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana can select notification.payload';
  END IF;

  IF NOT has_column_privilege('grafana', 'vibetype_private.account', 'created_at', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana cannot select account.created_at';
  END IF;

  IF NOT has_column_privilege('grafana', 'vibetype_private.notification', 'channel', 'SELECT') THEN
    RAISE EXCEPTION 'Test failed: grafana cannot select notification.channel';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT grafana_columns;

ROLLBACK;
