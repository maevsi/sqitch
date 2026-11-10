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

ROLLBACK;
