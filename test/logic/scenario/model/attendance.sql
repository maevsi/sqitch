\echo test_attendance...

BEGIN;

SAVEPOINT attendance_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAX UUID;
  eventA UUID;
  guestAB UUID;
  guestAX UUID;
  attendanceAB UUID;
  attendanceAX UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAX := vibetype_test.contact_create(accountA, 'x@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAX := vibetype_test.guest_create(accountA, eventA, contactAX);

  -- `attendance_create` reads the new row back through `RETURNING`, which the select policy has to allow.
  attendanceAB := vibetype_test.attendance_create(accountA, guestAB);
  attendanceAX := vibetype_test.attendance_create(accountA, guestAX);

  PERFORM vibetype_test.attendance_test('organizer sees all attendances of the own event', accountA, ARRAY[attendanceAB, attendanceAX]);
  PERFORM vibetype_test.attendance_test('guest sees the attendance of a contact referring to them', accountB, ARRAY[attendanceAB]);
  PERFORM vibetype_test.attendance_test('unrelated account sees no attendance', accountC, ARRAY[]::UUID[]);
  PERFORM vibetype_test.attendance_test('anonymous sees no attendance', NULL, ARRAY[]::UUID[]);

  PERFORM set_config('jwt.claims.guests', '["' || guestAX || '"]', true);
  PERFORM vibetype_test.attendance_test('anonymous sees the attendance of a claimed guest', NULL, ARRAY[attendanceAX]);
  PERFORM set_config('jwt.claims.guests', '', true);

  PERFORM set_config('jwt.claims.attendances', '["' || attendanceAB || '"]', true);
  PERFORM vibetype_test.attendance_test('anonymous sees a claimed attendance', NULL, ARRAY[attendanceAB]);
  PERFORM set_config('jwt.claims.attendances', '', true);

  PERFORM vibetype_test.account_block_create(accountB, accountA);

  PERFORM vibetype_test.attendance_test('organizer still sees attendances of a blocking guest', accountA, ARRAY[attendanceAB, attendanceAX]);
  PERFORM vibetype_test.attendance_test('guest does not see attendances created through a blocked account', accountB, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT attendance_select;

SAVEPOINT attendance_write;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  contactAX UUID;
  contactCX UUID;
  eventA UUID;
  eventC UUID;
  guestAB UUID;
  guestAC UUID;
  guestAX UUID;
  guestCX UUID;
  attendanceAB UUID;
  attendanceAX UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactAX := vibetype_test.contact_create(accountA, 'x@example.com');
  contactCX := vibetype_test.contact_create(accountC, 'x@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  guestAX := vibetype_test.guest_create(accountA, eventA, contactAX);
  guestCX := vibetype_test.guest_create(accountC, eventC, contactCX);

  attendanceAB := vibetype_test.attendance_create(accountA, guestAB);
  attendanceAX := vibetype_test.attendance_create(accountA, guestAX);

  BEGIN
    PERFORM vibetype_test.attendance_create(accountA, guestCX);
    RAISE EXCEPTION 'Test failed: checking in a guest of another organizer''s event should be denied';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;

  PERFORM vibetype_test.attendance_update_test('organizer updates an attendance of the own event', accountA, attendanceAX, TRUE);
  PERFORM vibetype_test.attendance_update_test('unrelated account cannot update an attendance', accountC, attendanceAX, FALSE);
  PERFORM vibetype_test.attendance_update_test('anonymous cannot update an attendance', NULL, attendanceAX, FALSE);

  PERFORM set_config('jwt.claims.guests', '["' || guestAX || '"]', true);
  PERFORM vibetype_test.attendance_update_test('anonymous updates the attendance of a claimed guest', NULL, attendanceAX, TRUE);
  PERFORM set_config('jwt.claims.guests', '', true);

  PERFORM vibetype_test.account_block_create(accountB, accountA);
  PERFORM vibetype_test.account_block_create(accountC, accountA);

  PERFORM vibetype_test.attendance_update_test('organizer cannot update an attendance of a blocking guest', accountA, attendanceAB, FALSE);
  PERFORM vibetype_test.attendance_update_test('organizer still updates an attendance of an unblocked guest', accountA, attendanceAX, TRUE);

  BEGIN
    PERFORM vibetype_test.attendance_create(accountA, guestAC);
    RAISE EXCEPTION 'Test failed: checking in a blocking guest should be denied';
  EXCEPTION WHEN insufficient_privilege THEN
    NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT attendance_write;

ROLLBACK;
