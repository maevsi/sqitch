\echo test_event_child...

BEGIN;

-- Visibility of the tables whose policies read `event` must follow event visibility:
-- A organizes a public event and a private event that B is invited to, each with an address
-- and a row in every child table. C is unrelated and organizes a private event.
SAVEPOINT event_child_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  addressA UUID;
  addressC UUID;
  addressPrivate UUID;
  eventPrivate UUID;
  eventPublic UUID;
  contactAB UUID;
  eventC UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventPublic := vibetype_test.event_create(accountA, 'Public event', 'public-event', '2025-06-01 20:00', 'public');
  eventPrivate := vibetype_test.event_create(accountA, 'Private event', 'private-event', '2025-06-01 20:00', 'private');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'private');
  PERFORM vibetype_test.guest_create(accountA, eventPrivate, contactAB);

  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  addressA := vibetype_test.event_child_create(accountA, eventPublic, 'Public address');
  addressPrivate := vibetype_test.event_child_create(accountA, eventPrivate, 'Private address');
  addressC := vibetype_test.event_child_create(accountC, eventC, 'Address of C');

  PERFORM vibetype_test.event_child_test('owner sees everything of the own events', accountA, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic, eventPrivate], ARRAY[addressA, addressPrivate]);
  PERFORM vibetype_test.event_child_test('invitee sees the private and the public event', accountB, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic, eventPrivate], ARRAY[addressA, addressPrivate]);
  PERFORM vibetype_test.event_child_test('unrelated account sees the public event and the own one', accountC, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic, eventC], ARRAY[addressA, addressC]);
  PERFORM vibetype_test.event_child_test('anonymous sees the public event only', NULL, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic], ARRAY[addressA]);

  PERFORM vibetype_test.account_block_create(accountA, accountC);

  PERFORM vibetype_test.event_child_test('owner is unaffected by blocking an account', accountA, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic, eventPrivate], ARRAY[addressA, addressPrivate]);
  PERFORM vibetype_test.event_child_test('blocked account sees nothing of the blocker', accountC, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventC], ARRAY[addressC]);
  PERFORM vibetype_test.event_child_test('anonymous is unaffected by blocks', NULL, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[eventPublic], ARRAY[addressA]);

  PERFORM vibetype_test.account_block_create(accountB, accountA);

  PERFORM vibetype_test.event_child_test('invitee sees nothing of a blocked organizer', accountB, ARRAY[eventPublic, eventPrivate, eventC], ARRAY[]::UUID[], ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT event_child_select;

ROLLBACK;
