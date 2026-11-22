\echo test_event_upload...

BEGIN;

-- An organizer can attach an own upload to an own event, but not another account's upload or to another account's event.
SAVEPOINT event_upload_insert;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _event_a UUID;
  _event_b UUID;
  _upload_a UUID;
  _upload_b UUID;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _event_a := vibetype_test.event_create(_account_a, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  _event_b := vibetype_test.event_create(_account_b, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(_account_b);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_b, 1) RETURNING id INTO _upload_b;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_a);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_a, 1) RETURNING id INTO _upload_a;

  INSERT INTO vibetype.event_upload(event_id, is_header_image, upload_id) VALUES (_event_a, TRUE, _upload_a);

  BEGIN
    INSERT INTO vibetype.event_upload(event_id, upload_id) VALUES (_event_a, _upload_b);
    RAISE EXCEPTION 'Test failed: another account''s upload was attached to an own event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  BEGIN
    INSERT INTO vibetype.event_upload(event_id, upload_id) VALUES (_event_b, _upload_a);
    RAISE EXCEPTION 'Test failed: an own upload was attached to another account''s event';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_upload_insert;

-- An upload attached to an event is visible to whoever sees the event, other uploads stay private.
SAVEPOINT upload_select_event;
DO $$
DECLARE
  _account_a UUID;
  _account_b UUID;
  _event_private UUID;
  _event_public UUID;
  _upload_private UUID;
  _upload_public UUID;
  _upload_unattached UUID;
BEGIN
  _account_a := vibetype_test.account_registration_verified('a', 'a@example.com');
  _account_b := vibetype_test.account_registration_verified('b', 'b@example.com');
  _event_private := vibetype_test.event_create(_account_a, 'Private event', 'event-private', '2025-06-01 20:00', 'private');
  _event_public := vibetype_test.event_create(_account_a, 'Public event', 'event-public', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(_account_a);
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_a, 1) RETURNING id INTO _upload_private;
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_a, 1) RETURNING id INTO _upload_public;
  INSERT INTO vibetype.upload(created_by, size_byte) VALUES (_account_a, 1) RETURNING id INTO _upload_unattached;
  INSERT INTO vibetype.event_upload(event_id, is_header_image, upload_id) VALUES (_event_private, TRUE, _upload_private);
  INSERT INTO vibetype.event_upload(event_id, is_header_image, upload_id) VALUES (_event_public, TRUE, _upload_public);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_b);
  PERFORM vibetype_test.uuid_array_test(
    'upload visibility for another account',
    ARRAY(SELECT id FROM vibetype.upload),
    ARRAY[_upload_public]::UUID[]
  );
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set_anonymous();
  PERFORM vibetype_test.uuid_array_test(
    'upload visibility for anonymous',
    ARRAY(SELECT id FROM vibetype.upload),
    ARRAY[_upload_public]::UUID[]
  );
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(_account_a);
  PERFORM vibetype_test.uuid_array_test(
    'upload visibility for the organizer',
    ARRAY(SELECT id FROM vibetype.upload),
    ARRAY[_upload_private, _upload_public, _upload_unattached]::UUID[]
  );
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT upload_select_event;

ROLLBACK;
