\echo test_guest_join...

BEGIN;

SAVEPOINT guest_join_public;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactBB UUID;
  eventA UUID;
  guestBA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactBB := vibetype_test.contact_select_by_account_id(accountB);
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountB);

  INSERT INTO vibetype.guest(contact_id, event_id, feedback)
  VALUES (contactBB, eventA, 'accepted')
  RETURNING id INTO guestBA;

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_test('the joined guest is visible to its account', accountB, ARRAY[guestBA]);
  PERFORM vibetype_test.guest_test('the joined guest is visible to the organizer', accountA, ARRAY[guestBA]);
END $$;
ROLLBACK TO SAVEPOINT guest_join_public;

SAVEPOINT guest_join_private;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'private');

  PERFORM vibetype_test.guest_join_rejected_test('a private event cannot be joined', accountB, eventA, vibetype_test.contact_select_by_account_id(accountB), '42501');
END $$;
ROLLBACK TO SAVEPOINT guest_join_private;

SAVEPOINT guest_join_contact_foreign;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactBC UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.guest_join_rejected_test('a public event cannot be joined for someone else', accountB, eventA, contactBC, '42501');
  PERFORM vibetype_test.guest_join_rejected_test('a public event cannot be joined with a contact created by someone else', accountC, eventA, contactBC, '42501');
END $$;
ROLLBACK TO SAVEPOINT guest_join_contact_foreign;

SAVEPOINT guest_join_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.guest_join_rejected_test('a public event of a blocking organizer cannot be joined', accountB, eventA, vibetype_test.contact_select_by_account_id(accountB), '42501');
END $$;
ROLLBACK TO SAVEPOINT guest_join_blocked;

SAVEPOINT guest_join_maximum;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);
  UPDATE vibetype.event SET guest_count_maximum = 1 WHERE id = eventA;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_create(accountB, eventA, vibetype_test.contact_select_by_account_id(accountB));

  PERFORM vibetype_test.guest_join_rejected_test('a full public event cannot be joined', accountC, eventA, vibetype_test.contact_select_by_account_id(accountC), '42501');
END $$;
ROLLBACK TO SAVEPOINT guest_join_maximum;

SAVEPOINT guest_join_maximum_statement;
DO $$
DECLARE
  accountA UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public', 1)
  RETURNING id INTO eventA;

  BEGIN
    PERFORM vibetype.create_guests(eventA, ARRAY[contactAB, contactAC]);
    RAISE EXCEPTION 'Test failed: one statement should not exceed the maximum guest count';
  EXCEPTION WHEN SQLSTATE 'VTGCM' THEN
    NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_join_maximum_statement;

ROLLBACK;
