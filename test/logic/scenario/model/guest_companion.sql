\echo test_guest_companion...

BEGIN;

SAVEPOINT guest_companion_request;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.guest_companion_rejected_test('inserts must not set companions', accountA,
    format('INSERT INTO vibetype.guest(contact_id, event_id, companion_count) VALUES (%L, %L, 1)', vibetype_test.contact_create(accountA, 'x@example.com'), eventA), '42501');

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 3 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS DISTINCT FROM 3 THEN
    RAISE EXCEPTION 'Test failed: the invitee should be able to request companions';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: a pending request must not take seats';
  END IF;

  PERFORM vibetype_test.guest_companion_rejected_test('the invitee cannot approve', accountB,
    format('UPDATE vibetype.guest SET companion_count = 3, companion_count_requested = NULL WHERE id = %L', guestAB), '42501');
  PERFORM vibetype_test.guest_companion_rejected_test('the invitee cannot approve without touching the request', accountB,
    format('UPDATE vibetype.guest SET companion_count = 1 WHERE id = %L', guestAB), '42501');

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 0 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a request of 0 should clear the request';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_request;

SAVEPOINT guest_companion_approve;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  contactAC UUID;
  accountC UUID;
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

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 3 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  -- Approve in full.
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 3 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count', accountA, guestAB) IS DISTINCT FROM 3
    OR vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: approving should set the companions and clear the request';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 5 THEN
    RAISE EXCEPTION 'Test failed: expected 5 seats (2 guests, 3 companions), got %', (SELECT guest_count FROM vibetype.event WHERE id = eventA);
  END IF;

  IF vibetype.guest_count(eventA) IS DISTINCT FROM 5 THEN
    RAISE EXCEPTION 'Test failed: guest_count() should count seats';
  END IF;

  -- The invitee can lower but not raise.
  PERFORM vibetype_test.guest_companion_rejected_test('the invitee cannot raise the approved companions', accountB,
    format('UPDATE vibetype.guest SET companion_count = 4 WHERE id = %L', guestAB), '42501');

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count = 1 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 3 THEN
    RAISE EXCEPTION 'Test failed: lowering should free seats';
  END IF;

  -- Approve fewer than requested.
  PERFORM vibetype_test.invoker_set(accountC);
  UPDATE vibetype.guest SET companion_count_requested = 4 WHERE id = guestAC;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_companion_rejected_test('the organizer cannot approve more than requested', accountA,
    format('UPDATE vibetype.guest SET companion_count = 5 WHERE id = %L', guestAC), '42501');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAC;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count', accountA, guestAC) IS DISTINCT FROM 2
    OR vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAC) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: approving fewer should set the lower value and clear the request';
  END IF;

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 5 THEN
    RAISE EXCEPTION 'Test failed: expected 5 seats after approving fewer';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_approve;

SAVEPOINT guest_companion_reject;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count_requested = NULL WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL
    OR vibetype_test.guest_companion_get('companion_count', accountA, guestAB) IS DISTINCT FROM 0
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: rejecting should clear the request and leave the seats';
  END IF;

  PERFORM vibetype_test.guest_companion_rejected_test('the organizer cannot request on behalf of the guest', accountA,
    format('UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = %L', guestAB), '42501');
END $$;
ROLLBACK TO SAVEPOINT guest_companion_reject;

SAVEPOINT guest_companion_stranger;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountC);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a stranger must not be able to request companions for a guest';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_stranger;

SAVEPOINT guest_companion_anonymous;
DO $$
DECLARE
  accountA UUID;
  contactAX UUID;
  eventA UUID;
  guestAX UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAX := vibetype_test.contact_create(accountA, 'x@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAX := vibetype_test.guest_create(accountA, eventA, contactAX);

  PERFORM vibetype_test.invoker_set_anonymous();
  PERFORM set_config('jwt.claims.guests', json_build_array(guestAX)::TEXT, true);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAX;
  PERFORM set_config('jwt.claims.guests', '', true);
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAX) IS DISTINCT FROM 2 THEN
    RAISE EXCEPTION 'Test failed: an anonymous guest with a claim should be able to request companions';
  END IF;

  PERFORM vibetype_test.invoker_set_anonymous();
  PERFORM set_config('jwt.claims.guests', json_build_array(guestAX)::TEXT, true);
  BEGIN
    UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAX;
    RAISE EXCEPTION 'Test failed: an anonymous guest must not approve companions';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
  PERFORM set_config('jwt.claims.guests', '', true);
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_companion_anonymous;

SAVEPOINT guest_companion_request_equal;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: a request equal to the approved count should be stored as NULL';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_request_equal;

SAVEPOINT guest_companion_delete;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAC);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 4 THEN
    RAISE EXCEPTION 'Test failed: expected 4 seats before the delete';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.guest WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: deleting a guest should free its companion seats';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_delete;

SAVEPOINT guest_companion_cascade;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAC);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.contact WHERE id = contactAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: a cascading contact delete should free the guest''s seats, got %', (SELECT guest_count FROM vibetype.event WHERE id = eventA);
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_cascade;

SAVEPOINT guest_companion_cancel;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 4 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  -- Cancel by the guest.
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = 'canceled' WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count', accountA, guestAB) IS DISTINCT FROM 0
    OR vibetype_test.guest_companion_get('companion_count_requested', accountA, guestAB) IS NOT NULL
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: canceling should reset the companions and free their seats';
  END IF;

  -- Cancel by the organizer through the override.
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = 'accepted', companion_count_requested = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 3 THEN
    RAISE EXCEPTION 'Test failed: expected 3 seats before the override';
  END IF;

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET feedback_override = 'canceled' WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  IF vibetype_test.guest_companion_get('companion_count', accountA, guestAB) IS DISTINCT FROM 0
    OR (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: canceling through the override should reset the companions and free their seats';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_companion_cancel;

SAVEPOINT guest_companion_maximum;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  contactAC UUID;
  contactAD UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactAD := vibetype_test.contact_create(accountA, 'd@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET guest_count_maximum = 3 WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count_requested = 3 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_companion_rejected_test('approving over the maximum fails', accountA,
    format('UPDATE vibetype.guest SET companion_count = 3 WHERE id = %L', guestAB), 'VTGCM');

  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 1 THEN
    RAISE EXCEPTION 'Test failed: a failed approval must leave the counter alone';
  END IF;

  -- Approving up to the maximum works and fills the event.
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET companion_count = 2 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_companion_rejected_test('inserting a guest into a full event fails', accountA,
    format('INSERT INTO vibetype.guest(contact_id, event_id) VALUES (%L, %L)', contactAC, eventA), '42501');

  -- Lowering below a lowered maximum still works.
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET guest_count_maximum = 1 WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET companion_count = 1 WHERE id = guestAB;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  IF (SELECT guest_count FROM vibetype.event WHERE id = eventA) IS DISTINCT FROM 2 THEN
    RAISE EXCEPTION 'Test failed: a decrease must succeed even above the maximum';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_companion_maximum;

ROLLBACK;
