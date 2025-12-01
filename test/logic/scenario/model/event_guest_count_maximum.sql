\echo test_event_guest_count_maximum...

BEGIN;

SAVEPOINT event_guest_count_maximum_null;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  maxCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  maxCount := vibetype.event_guest_count_maximum(eventA);

  -- Public event with no limit should return NULL
  IF maxCount IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: expected NULL for event with no guest limit, got %', maxCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_maximum_null;

SAVEPOINT event_guest_count_maximum_value;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  maxCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Create event with guest count maximum
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Limited Event', 'limited-event', '2025-06-01 20:00', 'public', 50)
  RETURNING id INTO eventA;

  maxCount := vibetype.event_guest_count_maximum(eventA);

  -- Should return the set limit
  IF maxCount IS NULL OR maxCount != 50 THEN
    RAISE EXCEPTION 'Test failed: expected 50 for event guest count maximum, got %', maxCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_maximum_value;

SAVEPOINT event_guest_count_maximum_inaccessible;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  maxCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Create private event
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Private Event', 'private-event', '2025-06-01 20:00', 'private', 30)
  RETURNING id INTO eventA;

  PERFORM vibetype_test.invoker_set(accountB);

  maxCount := vibetype.event_guest_count_maximum(eventA);

  -- Account B should not be able to see private event of account A
  IF maxCount IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: expected NULL for inaccessible event, got %', maxCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_maximum_inaccessible;

SAVEPOINT event_guest_count_maximum_organizer;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  maxCount INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Create private event
  INSERT INTO vibetype.event (created_by, name, slug, start, visibility, guest_count_maximum)
  VALUES (accountA, 'Private Event', 'private-event', '2025-06-01 20:00', 'private', 25)
  RETURNING id INTO eventA;

  maxCount := vibetype.event_guest_count_maximum(eventA);

  -- Organizer should be able to see their private event's guest count maximum
  IF maxCount IS NULL OR maxCount != 25 THEN
    RAISE EXCEPTION 'Test failed: organizer should see guest count maximum of 25, got %', maxCount;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_guest_count_maximum_organizer;

ROLLBACK;
