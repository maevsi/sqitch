\echo test_event/policy...

BEGIN;

SAVEPOINT event_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.event_test('event visibility without block (perspective A)', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.event_test('event visibility without block (perspective B)', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_select;

SAVEPOINT event_select_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.event_test('event visibility with block (perspective A)', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM vibetype_test.event_test('event visibility with block (perspective B)', accountB, ARRAY[eventB, eventC]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_select_block;

SAVEPOINT event_select_anonymous;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.event_test('anonymous event visibility without block', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.contact_test('anonymous contact visibility without block', null, ARRAY[]::UUID[]);
  PERFORM vibetype_test.guest_test('anonymous guest visibility without block', null, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_select_anonymous;

SAVEPOINT event_select_anonymous_block;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.event_test('anonymous event visibility with block', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.contact_test('anonymous contact visibility with block', null, ARRAY[]::UUID[]);
  PERFORM vibetype_test.guest_test('anonymous guest visibility with block', null, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_select_anonymous_block;

ROLLBACK;
