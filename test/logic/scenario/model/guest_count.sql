\echo test_guest_count...

BEGIN;

SAVEPOINT guest_count_zero;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  guestCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  guestCount := vibetype.guest_count(eventA);

  -- Should return 0 for event with no guests
  IF guestCount != 0 THEN
    RAISE EXCEPTION 'Test failed: expected 0 guests, got %', guestCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_count_zero;

SAVEPOINT guest_count_single;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  guestCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);

  guestCount := vibetype.guest_count(eventA);

  -- Should return 1 for event with one guest
  IF guestCount != 1 THEN
    RAISE EXCEPTION 'Test failed: expected 1 guest, got %', guestCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_count_single;

SAVEPOINT guest_count_multiple;
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
  guestCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);

  PERFORM vibetype_test.invoker_set(accountA);

  guestCount := vibetype.guest_count(eventA);

  -- Should return 2 for event with two guests
  IF guestCount != 2 THEN
    RAISE EXCEPTION 'Test failed: expected 2 guests, got %', guestCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_count_multiple;

SAVEPOINT guest_count_different_events;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  eventB UUID;
  guestAB UUID;
  guestCountA INTEGER;
  guestCountB INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  PERFORM vibetype_test.invoker_set(accountA);

  guestCountA := vibetype.guest_count(eventA);
  guestCountB := vibetype.guest_count(eventB);

  -- Event A should have 1 guest
  IF guestCountA != 1 THEN
    RAISE EXCEPTION 'Test failed: event A expected 1 guest, got %', guestCountA;
  END IF;

  -- Event B should have 0 guests
  IF guestCountB != 0 THEN
    RAISE EXCEPTION 'Test failed: event B expected 0 guests, got %', guestCountB;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT guest_count_different_events;

ROLLBACK;
