\echo test_events_invited...

BEGIN;

SAVEPOINT events_invited_basic;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  invitedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || accountB || '''';

  -- Get invited events for account B
  invitedEventIds := ARRAY(SELECT event_id FROM vibetype_private.events_invited());

  -- Account B should see event A (invited via contact)
  PERFORM vibetype_test.uuid_array_test('invited event appears in list', invitedEventIds, ARRAY[eventA]);
END $$;
ROLLBACK TO SAVEPOINT events_invited_basic;

SAVEPOINT events_invited_not_invited;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  eventA UUID;
  eventB UUID;
  guestAB UUID;
  invitedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || accountC || '''';

  -- Get invited events for account C
  invitedEventIds := ARRAY(SELECT event_id FROM vibetype_private.events_invited());

  -- Account C should not see event A or B (not invited)
  IF eventA = ANY(invitedEventIds) THEN
    RAISE EXCEPTION 'Test failed: account C should not see event A (not invited)';
  END IF;

  IF eventB = ANY(invitedEventIds) THEN
    RAISE EXCEPTION 'Test failed: account C should not see event B (not invited)';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT events_invited_not_invited;

SAVEPOINT events_invited_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  invitedEventIds UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  -- Account B blocks account A
  PERFORM vibetype_test.account_block_create(accountB, accountA);

  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || accountB || '''';

  -- Get invited events for account B
  invitedEventIds := ARRAY(SELECT event_id FROM vibetype_private.events_invited());

  -- Account B should not see event A (blocked the organizer)
  IF eventA = ANY(invitedEventIds) THEN
    RAISE EXCEPTION 'Test failed: account B should not see event A after blocking organizer';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT events_invited_blocked;

SAVEPOINT events_invited_guest_claim;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
  guestAB UUID;
  invitedEventIds UUID[];
  guestClaimArray UUID[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);

  -- Simulate guest claim by adding to array
  guestClaimArray := vibetype_test.guest_claim_from_account_guest(accountB);

  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || accountB || '''';

  -- Get invited events for account B (should include via guest claim)
  invitedEventIds := ARRAY(SELECT event_id FROM vibetype_private.events_invited());

  -- Account B should see event A via guest claim
  PERFORM vibetype_test.uuid_array_test('invited event via guest claim appears in list', invitedEventIds, ARRAY[eventA]);
END $$;
ROLLBACK TO SAVEPOINT events_invited_guest_claim;

ROLLBACK;
