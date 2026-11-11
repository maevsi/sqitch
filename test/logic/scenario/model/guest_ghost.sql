\echo test_guest_ghost...

BEGIN;

SAVEPOINT guest_ghost_attendees;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  accountD UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  guestAB UUID;
  guestAC UUID;
  _attendees UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  accountD := vibetype_test.account_registration_verified('d', 'd@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event', 'event', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);

  PERFORM vibetype_test.invoker_set(accountD);
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[]) INTO _attendees FROM vibetype.event e, vibetype.event_attendees(e) a WHERE e.id = eventA;
  PERFORM vibetype_test.uuid_array_test('an invited guest is no attendee', _attendees, ARRAY[]::UUID[]);

  -- the organizer cannot make an account attend
  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = guestAC;

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = guestAB;

  PERFORM vibetype_test.invoker_set(accountD);
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[]) INTO _attendees FROM vibetype.event e, vibetype.event_attendees(e) a WHERE e.id = eventA;
  PERFORM vibetype_test.uuid_array_test('only a guest that accepted itself is an attendee', _attendees, ARRAY[accountB]);

  -- ghost mode
  PERFORM vibetype_test.invoker_set(accountA);
  BEGIN
    UPDATE vibetype.guest SET is_ghost = TRUE WHERE id = guestAB;
    RAISE EXCEPTION 'Test failed: the organizer could change a guest''s ghost mode';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET is_ghost = TRUE WHERE id = guestAB;

  PERFORM vibetype_test.invoker_set(accountD);
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[]) INTO _attendees FROM vibetype.event e, vibetype.event_attendees(e) a WHERE e.id = eventA;
  PERFORM vibetype_test.uuid_array_test('a ghost is no attendee', _attendees, ARRAY[]::UUID[]);

  PERFORM vibetype_test.invoker_set(accountB);
  UPDATE vibetype.guest SET is_ghost = FALSE WHERE id = guestAB;

  -- blocks
  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.account_block_create(accountB, accountD);
  PERFORM vibetype_test.invoker_set(accountD);
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[]) INTO _attendees FROM vibetype.event e, vibetype.event_attendees(e) a WHERE e.id = eventA;
  PERFORM vibetype_test.uuid_array_test('an attendee involved in a block is hidden', _attendees, ARRAY[]::UUID[]);

  PERFORM vibetype_test.invoker_set(accountC);
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[]) INTO _attendees FROM vibetype.event e, vibetype.event_attendees(e) a WHERE e.id = eventA;
  PERFORM vibetype_test.uuid_array_test('other accounts still see the attendee', _attendees, ARRAY[accountB]);

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_ghost_attendees;

SAVEPOINT guest_ghost_attendees_event_visibility;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  _event vibetype.event;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event', 'event', '2025-06-01 20:00', 'private');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountB);
  SELECT * INTO _event FROM vibetype.event WHERE id = eventA;
  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id = guestAB;
  ASSERT (SELECT count(*) FROM vibetype.event_attendees(_event)) = 1, 'Test failed: a guest does not see the attendees of its private event';

  PERFORM vibetype_test.invoker_set(accountC);
  ASSERT (SELECT count(*) FROM vibetype.event_attendees(_event)) = 0, 'Test failed: the attendees of an invisible event are visible';

  PERFORM vibetype_test.invoker_set_anonymous();
  BEGIN
    PERFORM 1 FROM vibetype.event_attendees(_event);
    RAISE EXCEPTION 'Test failed: anonymous could list attendees';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_ghost_attendees_event_visibility;

ROLLBACK;
