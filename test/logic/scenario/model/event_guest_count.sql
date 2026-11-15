\echo test_event_guest_count...

BEGIN;

SAVEPOINT event_guest_count_insert_delete;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  eventB UUID;
  guestAB UUID;
  guestAC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 0 THEN
    RAISE EXCEPTION 'Test failed: a new event must have no guests';
  END IF;

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: expected 1 guest after the first insert';
  END IF;

  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 2 THEN
    RAISE EXCEPTION 'Test failed: expected 2 guests after the second insert';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 0 THEN
    RAISE EXCEPTION 'Test failed: guests of event A must not count for event B';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: expected 1 guest after a delete';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM vibetype.guest_count(eventA) THEN
    RAISE EXCEPTION 'Test failed: the counter must match guest_count()';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_insert_delete;

-- One statement touching several events updates each of them once, with its own number of guests.
SAVEPOINT event_guest_count_statement;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  eventB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.guest (event_id, contact_id) VALUES
    (eventA, contactAB), (eventA, contactAC), (eventB, contactAB);
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 2
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: a multi-row insert must count per event';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 0
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 0 THEN
    RAISE EXCEPTION 'Test failed: a multi-row delete must count per event';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_statement;

-- Deleting an event removes its guests by cascade, which must not fail on the vanishing event row.
SAVEPOINT event_guest_count_event_delete;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  eventB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);
  PERFORM vibetype_test.guest_create(accountA, eventB, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.event WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  IF EXISTS (SELECT 1 FROM vibetype.guest WHERE event_id = eventA) THEN
    RAISE EXCEPTION 'Test failed: guests of a deleted event must be gone';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: the other event must keep its guest';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_event_delete;

-- Deleting an account cascades through its events and contacts, both of which remove guests, while other events keep theirs.
SAVEPOINT event_guest_count_account_delete;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactBC UUID;
  eventA UUID;
  eventB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event B', 'event-b', '2025-07-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);
  PERFORM vibetype_test.guest_create(accountB, eventB, contactBC);

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype.account_delete('password');
  PERFORM vibetype_test.invoker_set_previous();

  IF EXISTS (SELECT 1 FROM vibetype.event WHERE id = eventA) THEN
    RAISE EXCEPTION 'Test failed: the deleted account''s event must be gone';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: the other account''s event must keep its guest';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_account_delete;

-- Deleting an account removes the guests created through peer contacts that only referred to it.
SAVEPOINT event_guest_count_peer_contact;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactBA UUID;
  eventB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.contact (created_by, account_id) VALUES (accountB, accountA) RETURNING id INTO contactBA;
  PERFORM vibetype_test.invoker_set_previous();

  eventB := vibetype_test.event_create(accountB, 'Event B', 'event-b', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountB, eventB, contactBA);

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: expected 1 guest before the account deletion';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype.account_delete('password');
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM 0
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventB) IS DISTINCT FROM vibetype.guest_count(eventB) THEN
    RAISE EXCEPTION 'Test failed: expected 0 guests after the referenced account was deleted';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_peer_contact;

-- Deleting a contact removes its guests by cascade.
SAVEPOINT event_guest_count_contact_delete;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.contact WHERE id = contactAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 0 THEN
    RAISE EXCEPTION 'Test failed: expected 0 guests after the contact was deleted';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_contact_delete;

-- The counter is not writable by API roles, on insert and on update.
SAVEPOINT event_guest_count_grants_update;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.event SET guest_count = 5 WHERE id = eventA;
    RAISE EXCEPTION 'Test failed: updating guest_count must be refused';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  -- every other column stays writable
  UPDATE vibetype.event SET name = 'Renamed', is_archived = TRUE WHERE id = eventA;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_grants_update;

SAVEPOINT event_guest_count_grants_insert;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count)
    VALUES (accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public', 5);
    RAISE EXCEPTION 'Test failed: inserting guest_count must be refused';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_grants_insert;

-- A capped event stops accepting guests once full, and listing it hides it from others.
SAVEPOINT event_guest_count_capped;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Capped', 'capped', '2025-06-01 20:00', 'public', 1)
  RETURNING id INTO eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.event_test('visible while free, anonymous', NULL, ARRAY[eventA]);

  PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.event_test('hidden when full, anonymous', NULL, ARRAY[]::UUID[]);
  PERFORM vibetype_test.event_test('hidden when full, uninvited account', accountC, ARRAY[]::UUID[]);
  PERFORM vibetype_test.event_test('visible when full, organizer', accountA, ARRAY[eventA]);
  PERFORM vibetype_test.event_test('visible when full, invited account', accountB, ARRAY[eventA]);

  BEGIN
    PERFORM vibetype_test.guest_create(accountA, eventA, contactAC);
    RAISE EXCEPTION 'Test failed: a full event must refuse another guest';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      IF SQLSTATE != '42501' THEN
        RAISE;
      END IF;
  END;

  -- leaving a seat free again reopens the event
  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest WHERE event_id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.event_test('visible after a seat was freed, anonymous', NULL, ARRAY[eventA]);
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAC);
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_capped;

ROLLBACK;
