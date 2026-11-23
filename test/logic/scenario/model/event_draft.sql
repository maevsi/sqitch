\echo test_event_draft...

BEGIN;

SAVEPOINT event_draft_visibility;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  _visibility TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  FOREACH _visibility IN ARRAY ARRAY['public', 'private'] LOOP
    eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', _visibility);
    guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

    PERFORM vibetype_test.invoker_set(accountA);
    UPDATE vibetype.event SET published_at = NULL WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.event_test(_visibility || ' draft is invisible to anonymous users', NULL, ARRAY[]::UUID[]);
    PERFORM vibetype_test.event_test(_visibility || ' draft is invisible to other accounts', accountC, ARRAY[]::UUID[]);

    PERFORM vibetype_test.guest_claim_set(accountB);
    PERFORM vibetype_test.event_test(_visibility || ' draft is invisible to invited guests', accountB, ARRAY[]::UUID[]);
    PERFORM vibetype_test.event_test(_visibility || ' draft is visible to the organizer', accountA, ARRAY[eventA]);

    PERFORM vibetype_test.invoker_set_anonymous();
    IF EXISTS (SELECT 1 FROM vibetype.event) THEN
      RAISE EXCEPTION '% draft is visible through guest claims', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountA);
    UPDATE vibetype.event SET published_at = CURRENT_TIMESTAMP WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.event_test(_visibility || ' published event is visible to the organizer', accountA, ARRAY[eventA]);
    PERFORM vibetype_test.event_test(_visibility || ' published event is visible to invited guests', accountB, ARRAY[eventA]);
    PERFORM vibetype_test.invoker_set_anonymous();
    IF NOT EXISTS (SELECT 1 FROM vibetype.event) THEN
      RAISE EXCEPTION '% published event is invisible through guest claims', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM set_config('jwt.claims.guests', '', true);
    PERFORM vibetype_test.event_test(
      _visibility || ' published event visibility to other accounts',
      accountC,
      CASE WHEN _visibility = 'public' THEN ARRAY[eventA] ELSE ARRAY[]::UUID[] END
    );

    PERFORM vibetype_test.invoker_set(accountA);
    DELETE FROM vibetype.event WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT event_draft_visibility;

SAVEPOINT event_draft_join;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactBB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactBB := vibetype_test.contact_select_by_account_id(accountB);
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET published_at = NULL WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_join_rejected_test('an unpublished public event cannot be joined', accountB, eventA, contactBB, '42501');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET published_at = CURRENT_TIMESTAMP WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.guest(contact_id, event_id) VALUES (contactBB, eventA);
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_draft_join;

SAVEPOINT event_draft_guest_count_maximum;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  _visibility TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  FOREACH _visibility IN ARRAY ARRAY['public', 'private'] LOOP
    eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', _visibility);
    PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);

    PERFORM vibetype_test.invoker_set(accountA);
    UPDATE vibetype.event SET published_at = NULL, guest_count_maximum = 10 WHERE id = eventA;
    IF vibetype.event_guest_count_maximum(eventA) IS DISTINCT FROM 10 THEN
      RAISE EXCEPTION '% draft: the organizer should get the maximum guest count', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountB);
    IF vibetype.event_guest_count_maximum(eventA) IS NOT NULL THEN
      RAISE EXCEPTION '% draft: an invited guest should not get the maximum guest count', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set_anonymous();
    IF vibetype.event_guest_count_maximum(eventA) IS NOT NULL THEN
      RAISE EXCEPTION '% draft: an anonymous invoker should not get the maximum guest count', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountA);
    UPDATE vibetype.event SET published_at = CURRENT_TIMESTAMP WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountB);
    IF vibetype.event_guest_count_maximum(eventA) IS DISTINCT FROM 10 THEN
      RAISE EXCEPTION '% published: an invited guest should get the maximum guest count', _visibility;
    END IF;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountA);
    DELETE FROM vibetype.event WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT event_draft_guest_count_maximum;

SAVEPOINT event_draft_invite;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'private');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET published_at = NULL WHERE id = eventA;

  BEGIN
    PERFORM vibetype.invite(guestAB, 'de');
    RAISE EXCEPTION 'Test failed (event_draft_invite): inviting to an unpublished event should fail';
  EXCEPTION WHEN OTHERS THEN
    IF SQLSTATE <> 'VTEUP' THEN
      RAISE EXCEPTION 'Test failed (event_draft_invite): expected VTEUP, got % (%)', SQLSTATE, SQLERRM;
    END IF;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_draft_invite;

SAVEPOINT event_draft_by_attendance_id;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  attendanceB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'private');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  attendanceB := vibetype_test.attendance_create(accountA, guestAB);

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET published_at = NULL WHERE id = eventA;

  IF (SELECT id FROM vibetype.event_by_attendance_id(attendanceB)) IS DISTINCT FROM eventA THEN
    RAISE EXCEPTION 'Test failed (event_draft_by_attendance_id): the organizer should get the draft';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  IF (SELECT id FROM vibetype.event_by_attendance_id(attendanceB)) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed (event_draft_by_attendance_id): an attendee should not get the draft';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET published_at = CURRENT_TIMESTAMP WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  IF (SELECT id FROM vibetype.event_by_attendance_id(attendanceB)) IS DISTINCT FROM eventA THEN
    RAISE EXCEPTION 'Test failed (event_draft_by_attendance_id): an attendee should get the published event';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT event_draft_by_attendance_id;

SAVEPOINT event_draft_scheduled;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  _visibility TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');

  FOREACH _visibility IN ARRAY ARRAY['public', 'private'] LOOP
    eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', _visibility);
    guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

    PERFORM vibetype_test.invoker_set(accountA);
    UPDATE vibetype.event SET published_at = CURRENT_TIMESTAMP + INTERVAL '1 day' WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.event_test(_visibility || ' scheduled event is invisible to anonymous users', NULL, ARRAY[]::UUID[]);
    PERFORM vibetype_test.event_test(_visibility || ' scheduled event is invisible to other accounts', accountC, ARRAY[]::UUID[]);

    PERFORM vibetype_test.guest_claim_set(accountB);
    PERFORM vibetype_test.event_test(_visibility || ' scheduled event is invisible to invited guests', accountB, ARRAY[]::UUID[]);
    PERFORM vibetype_test.event_test(_visibility || ' scheduled event is visible to the organizer', accountA, ARRAY[eventA]);
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountA);
    BEGIN
      PERFORM vibetype.invite(guestAB, 'de');
      RAISE EXCEPTION 'Test failed (event_draft_scheduled): inviting to a scheduled event should fail';
    EXCEPTION WHEN OTHERS THEN
      IF SQLSTATE <> 'VTEUP' THEN
        RAISE EXCEPTION 'Test failed (event_draft_scheduled): expected VTEUP, got % (%)', SQLSTATE, SQLERRM;
      END IF;
    END;
    PERFORM vibetype_test.invoker_set_previous();

    PERFORM vibetype_test.invoker_set(accountA);
    DELETE FROM vibetype.event WHERE id = eventA;
    PERFORM vibetype_test.invoker_set_previous();
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT event_draft_scheduled;

ROLLBACK;
