\echo test_events_organized...

BEGIN;

SAVEPOINT events_organized_single;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  organizedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get organized events for account A
  organizedEventIds := ARRAY(SELECT event_id FROM vibetype.events_organized());

  -- Account A should see their event
  PERFORM vibetype_test.uuid_array_test('organized event appears in list', organizedEventIds, ARRAY[eventA]);
END $$;
ROLLBACK TO SAVEPOINT events_organized_single;

SAVEPOINT events_organized_multiple;
DO $$
DECLARE
  accountA UUID;
  eventA UUID;
  eventB UUID;
  eventC UUID;
  organizedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountA, 'Event B', 'event-b', '2025-07-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountA, 'Event C', 'event-c', '2025-08-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get organized events for account A
  organizedEventIds := ARRAY(SELECT event_id FROM vibetype.events_organized());

  -- Account A should see all their events
  PERFORM vibetype_test.uuid_array_test('all organized events appear in list', organizedEventIds, ARRAY[eventA, eventB, eventC]);
END $$;
ROLLBACK TO SAVEPOINT events_organized_multiple;

SAVEPOINT events_organized_not_organizer;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  eventA UUID;
  organizedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.invoker_set(accountB);

  -- Get organized events for account B
  organizedEventIds := ARRAY(SELECT event_id FROM vibetype.events_organized());

  -- Account B should not see event A (not the organizer)
  IF eventA = ANY(organizedEventIds) THEN
    RAISE EXCEPTION 'Test failed: account B should not see event A (not the organizer)';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT events_organized_not_organizer;

SAVEPOINT events_organized_empty;
DO $$
DECLARE
  accountA UUID;
  organizedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  -- Get organized events for account A (should be empty)
  organizedEventIds := ARRAY(SELECT event_id FROM vibetype.events_organized());

  -- Should return empty array
  IF array_length(organizedEventIds, 1) IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: account A should have no organized events, found %', array_length(organizedEventIds, 1);
  END IF;
END $$;
ROLLBACK TO SAVEPOINT events_organized_empty;

ROLLBACK;
