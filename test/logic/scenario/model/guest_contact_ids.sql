\echo test_guest_contact_ids...

BEGIN;

SAVEPOINT guest_contact_ids_organizer;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  contactIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get contact IDs for account A (event organizer)
  contactIds := ARRAY(SELECT contact_id FROM vibetype.guest_contact_ids());

  -- Account A should see contact AB
  PERFORM vibetype_test.uuid_array_test('organizer sees guest contact', contactIds, ARRAY[contactAB]);
END $$;
ROLLBACK TO SAVEPOINT guest_contact_ids_organizer;

SAVEPOINT guest_contact_ids_guest_claim;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  contactIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  -- Simulate guest claim
  PERFORM vibetype_test.invoker_set(accountB);
  PERFORM vibetype_test.guest_claim_set(accountB);

  -- Get contact IDs for account B (guest with claim)
  contactIds := ARRAY(SELECT contact_id FROM vibetype.guest_contact_ids());

  -- Account B should see contact AB through guest claim
  PERFORM vibetype_test.uuid_array_test('guest sees contact via guest claim', contactIds, ARRAY[contactAB]);
END $$;
ROLLBACK TO SAVEPOINT guest_contact_ids_guest_claim;

SAVEPOINT guest_contact_ids_blocked;
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
  contactIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);

  -- Account A blocks account B
  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get contact IDs for account A
  contactIds := ARRAY(SELECT contact_id FROM vibetype.guest_contact_ids());

  -- Account A should not see contact AB (blocked account B)
  IF contactAB = ANY(contactIds) THEN
    RAISE EXCEPTION 'Test failed: should not see contact of blocked account';
  END IF;

  -- Account A should still see contact AC
  PERFORM vibetype_test.uuid_array_test('organizer sees non-blocked guest contact', contactIds, ARRAY[contactAC]);
END $$;
ROLLBACK TO SAVEPOINT guest_contact_ids_blocked;

SAVEPOINT guest_contact_ids_multiple_events;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  contactAC UUID;
  eventA UUID;
  eventB UUID;
  guestAB1 UUID;
  guestAC UUID;
  guestAB2 UUID;
  contactIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');
  guestAB1 := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  guestAB2 := vibetype_test.guest_create(accountA, eventB, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get contact IDs for account A
  contactIds := ARRAY(SELECT contact_id FROM vibetype.guest_contact_ids());

  -- Account A should see both contacts (no duplicates)
  PERFORM vibetype_test.uuid_array_test('organizer sees all guest contacts', contactIds, ARRAY[contactAB, contactAC]);
END $$;
ROLLBACK TO SAVEPOINT guest_contact_ids_multiple_events;

ROLLBACK;
