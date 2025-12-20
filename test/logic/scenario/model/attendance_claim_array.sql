\echo test_attendance_claim_array...

BEGIN;

SAVEPOINT attendance_claim_array;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
  guestAB UUID;
  guestAC UUID;
  guestBA UUID;
  guestBC UUID;
  guestCA UUID;
  guestCB UUID;
  attendanceBA UUID;
  attendanceCA UUID;
  attendanceClaimArray UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  guestBA := vibetype_test.guest_create(accountB, eventB, contactBA);
  guestBC := vibetype_test.guest_create(accountB, eventB, contactBC);
  guestCA := vibetype_test.guest_create(accountC, eventC, contactCA);
  guestCB := vibetype_test.guest_create(accountC, eventC, contactCB);

  -- Create attendances for guests (as organizers)
  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.attendance (guest_id) VALUES (guestBA) RETURNING id INTO attendanceBA;

  PERFORM vibetype_test.invoker_set(accountC);
  INSERT INTO vibetype.attendance (guest_id) VALUES (guestCA) RETURNING id INTO attendanceCA;

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.attendance_claim_set(accountA);

  attendanceClaimArray := vibetype.attendance_claim_array();
  PERFORM vibetype_test.uuid_array_test('attendance claim includes data without block', attendanceClaimArray, ARRAY[attendanceBA, attendanceCA]);
END $$;
ROLLBACK TO SAVEPOINT attendance_claim_array;

SAVEPOINT attendance_claim_array_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAC UUID;
  contactBA UUID;
  contactBC UUID;
  contactCA UUID;
  contactCB UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
  guestAB UUID;
  guestAC UUID;
  guestBA UUID;
  guestBC UUID;
  guestCA UUID;
  guestCB UUID;
  attendanceAB UUID;
  attendanceBA UUID;
  attendanceCA UUID;
  attendanceClaimArray UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  guestBA := vibetype_test.guest_create(accountB, eventB, contactBA);
  guestBC := vibetype_test.guest_create(accountB, eventB, contactBC);
  guestCA := vibetype_test.guest_create(accountC, eventC, contactCA);
  guestCB := vibetype_test.guest_create(accountC, eventC, contactCB);

  -- Create attendances for guests (as organizers)
  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.attendance (guest_id) VALUES (guestAB) RETURNING id INTO attendanceAB;

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.attendance (guest_id) VALUES (guestBA) RETURNING id INTO attendanceBA;

  PERFORM vibetype_test.invoker_set(accountC);
  INSERT INTO vibetype.attendance (guest_id) VALUES (guestCA) RETURNING id INTO attendanceCA;

  -- Block account B, so attendance BA should be filtered out
  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.attendance_claim_set(accountA);

  attendanceClaimArray := vibetype.attendance_claim_array();
  PERFORM vibetype_test.uuid_array_test('attendance claim filters blocked accounts', attendanceClaimArray, ARRAY[attendanceCA]);
END $$;
ROLLBACK TO SAVEPOINT attendance_claim_array_block;

ROLLBACK;
