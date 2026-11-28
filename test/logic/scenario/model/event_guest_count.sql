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

-- The accepted counter only holds seats of guests who accepted, next to the all-seats counter.
CREATE FUNCTION pg_temp.expect(_test_case TEXT, _event_id UUID, _guest_count INTEGER, _guest_count_accepted INTEGER) RETURNS VOID
    LANGUAGE plpgsql AS $$
DECLARE
  _event vibetype.event;
BEGIN
  SELECT * INTO _event FROM vibetype.event WHERE id = _event_id;

  IF _event.guest_count IS DISTINCT FROM _guest_count OR _event.guest_count_accepted IS DISTINCT FROM _guest_count_accepted THEN
    RAISE EXCEPTION 'Test failed: % expected counters (%, %), got (%, %)',
      _test_case, _guest_count, _guest_count_accepted, _event.guest_count, _event.guest_count_accepted;
  END IF;
END $$;

CREATE FUNCTION pg_temp.set_feedback(_account_id UUID, _guest_id UUID, _feedback vibetype.invitation_feedback) RETURNS VOID
    LANGUAGE plpgsql AS $$
DECLARE
  _rows INTEGER;
BEGIN
  PERFORM vibetype_test.invoker_set(_account_id);
  UPDATE vibetype.guest SET feedback = _feedback WHERE id = _guest_id;
  GET DIAGNOSTICS _rows = ROW_COUNT;
  PERFORM vibetype_test.invoker_set_previous();

  IF _rows <> 1 THEN
    RAISE EXCEPTION 'Test failed: the feedback update must reach exactly one guest, reached % (account %, guest %, feedback %)', _rows, _account_id, _guest_id, _feedback;
  END IF;
END $$;

CREATE FUNCTION pg_temp.set_override(_account_id UUID, _guest_id UUID, _feedback vibetype.invitation_feedback) RETURNS VOID
    LANGUAGE plpgsql AS $$
BEGIN
  PERFORM vibetype_test.invoker_set(_account_id);
  UPDATE vibetype.guest SET feedback_override = _feedback WHERE id = _guest_id;
  PERFORM vibetype_test.invoker_set_previous();
END $$;

-- The guest requests companions and the organizer approves them in full, lowering is up to the guest.
CREATE FUNCTION pg_temp.set_companions(_organizer_id UUID, _account_id UUID, _guest_id UUID, _count INTEGER, _lower BOOLEAN DEFAULT FALSE) RETURNS VOID
    LANGUAGE plpgsql AS $$
BEGIN
  IF _lower THEN
    PERFORM vibetype_test.invoker_set(_account_id);
    UPDATE vibetype.guest SET companion_count = _count WHERE id = _guest_id;
    PERFORM vibetype_test.invoker_set_previous();
  ELSE
    PERFORM vibetype_test.invoker_set(_account_id);
    UPDATE vibetype.guest SET companion_count_requested = _count WHERE id = _guest_id;
    PERFORM vibetype_test.invoker_set_previous();
    PERFORM vibetype_test.invoker_set(_organizer_id);
    UPDATE vibetype.guest SET companion_count = _count WHERE id = _guest_id;
    PERFORM vibetype_test.invoker_set_previous();
  END IF;
END $$;

SAVEPOINT event_guest_count_accepted;
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

  -- unanswered guests take seats but are not accepted
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  PERFORM pg_temp.expect('unanswered insert', eventA, 1, 0);

  -- accepted and canceled guests inserted in one statement, spanning two events
  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.guest (event_id, contact_id, feedback) VALUES
    (eventA, contactAC, 'accepted'), (eventB, contactAB, 'accepted'), (eventB, contactAC, 'canceled');
  SELECT id INTO guestAC FROM vibetype.guest WHERE event_id = eventA AND contact_id = contactAC;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM pg_temp.expect('multi-row insert, event A', eventA, 2, 1);
  PERFORM pg_temp.expect('multi-row insert, event B', eventB, 2, 1);

  -- unanswered to accepted
  PERFORM pg_temp.set_feedback(accountB, guestAB, 'accepted');
  PERFORM pg_temp.expect('NULL to accepted', eventA, 2, 2);

  -- accepted to canceled
  PERFORM pg_temp.set_feedback(accountB, guestAB, 'canceled');
  PERFORM pg_temp.expect('accepted to canceled', eventA, 2, 1);

  -- accepted to unanswered
  PERFORM pg_temp.set_feedback(accountC, guestAC, NULL);
  PERFORM pg_temp.expect('accepted to NULL', eventA, 2, 0);

  PERFORM pg_temp.set_feedback(accountC, guestAC, 'accepted');
  PERFORM pg_temp.expect('NULL to accepted again', eventA, 2, 1);

  -- companions of an accepted guest take accepted seats
  PERFORM pg_temp.set_companions(accountA, accountC, guestAC, 2);
  PERFORM pg_temp.expect('companions on an accepted guest', eventA, 4, 3);

  PERFORM pg_temp.set_companions(accountA, accountC, guestAC, 1, TRUE);
  PERFORM pg_temp.expect('fewer companions on an accepted guest', eventA, 3, 2);

  -- companions of an unanswered guest only take seats
  PERFORM pg_temp.set_feedback(accountC, guestAC, NULL);
  PERFORM pg_temp.expect('accepted with companions to NULL', eventA, 3, 0);
  PERFORM pg_temp.set_companions(accountA, accountC, guestAC, 2);
  PERFORM pg_temp.expect('companions on an unanswered guest', eventA, 4, 0);

  -- accepting with companions, then canceling drops the companions as well
  PERFORM pg_temp.set_feedback(accountC, guestAC, 'accepted');
  PERFORM pg_temp.expect('unanswered with companions to accepted', eventA, 4, 3);
  PERFORM pg_temp.set_feedback(accountC, guestAC, 'canceled');
  PERFORM pg_temp.expect('accepted with companions to canceled', eventA, 2, 0);

  -- one update statement spanning two events, as the guest invited to both
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = NULL WHERE contact_id = contactAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM pg_temp.expect('multi-event update to NULL, event A', eventA, 2, 0);
  PERFORM pg_temp.expect('multi-event update to NULL, event B', eventB, 2, 0);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE contact_id = contactAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM pg_temp.expect('multi-event update to accepted, event A', eventA, 2, 1);
  PERFORM pg_temp.expect('multi-event update to accepted, event B', eventB, 2, 1);

  -- delete of an accepted guest
  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM pg_temp.expect('delete of an accepted guest', eventA, 1, 0);

  -- cascade delete of the guests with their event
  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.event WHERE id = eventB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM pg_temp.expect('delete of another event', eventA, 1, 0);

  -- the counter always matches the accepted seats
  IF (SELECT guest_count_accepted FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM (
    SELECT COALESCE(SUM(1 + companion_count), 0) FROM vibetype.guest WHERE event_id = eventA AND feedback = 'accepted'
  ) THEN
    RAISE EXCEPTION 'Test failed: the accepted counter must match the accepted seats';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_accepted;

-- The organizer's override takes precedence over the guest's own feedback.
SAVEPOINT event_guest_count_accepted_override;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  guestAB UUID;
  guestAC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  PERFORM pg_temp.set_companions(accountA, accountB, guestAB, 2);
  PERFORM pg_temp.expect('setup', eventA, 4, 0);

  -- override on an unanswered guest
  PERFORM pg_temp.set_override(accountA, guestAB, 'accepted');
  PERFORM pg_temp.expect('override accepted on an unanswered guest', eventA, 4, 3);

  -- the guest's own feedback does not move the counter while the override is set
  PERFORM pg_temp.set_feedback(accountB, guestAB, 'canceled');
  PERFORM pg_temp.expect('feedback while an override is set', eventA, 4, 3);

  -- clearing the override restores the guest's own feedback
  PERFORM pg_temp.set_override(accountA, guestAB, NULL);
  PERFORM pg_temp.expect('override cleared, own feedback canceled', eventA, 2, 0);
  PERFORM pg_temp.set_feedback(accountB, guestAB, 'accepted');
  PERFORM pg_temp.expect('own feedback accepted', eventA, 2, 1);

  -- override canceled on an accepted guest
  PERFORM pg_temp.set_override(accountA, guestAB, 'canceled');
  PERFORM pg_temp.expect('override canceled on an accepted guest', eventA, 2, 0);

  PERFORM pg_temp.set_override(accountA, guestAB, NULL);
  PERFORM pg_temp.expect('override canceled cleared', eventA, 2, 1);
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_accepted_override;

-- The counter is maintained by triggers only.
SAVEPOINT event_guest_count_accepted_privilege;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.event SET guest_count_accepted = 5 WHERE id = eventA;
    RAISE EXCEPTION 'Test failed: an account must not update guest_count_accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  BEGIN
    INSERT INTO vibetype.event (name, slug, start, visibility, created_by, guest_count_accepted)
    VALUES ('Event X', 'event-x', '2025-06-01 20:00', 'public', accountA, 5);
    RAISE EXCEPTION 'Test failed: an account must not insert guest_count_accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_accepted_privilege;

ROLLBACK;
