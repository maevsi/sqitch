\echo test_guest_claim_array...

BEGIN;

SAVEPOINT guest_claim_array;
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
  guestClaimArray UUID[];
  guestClaimArrayNew UUID[];
  rec RECORD;
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

  PERFORM vibetype_test.invoker_set(accountC);

  FOR rec IN
    SELECT * FROM vibetype.create_guests(eventC, ARRAY[contactCA, contactCB])
  LOOP
    IF rec.contact_id = contactCA THEN
      guestCA := rec.id;
    ELSIF rec.contact_id = contactCB THEN
      guestCB := rec.id;
    END IF;
  END LOOP;

  PERFORM vibetype_test.invoker_set_empty();

  guestClaimArray := vibetype_test.guest_claim_from_account_guest(accountA);
  PERFORM vibetype_test.uuid_array_test('guest claim was added without block', guestClaimArray, ARRAY[guestBA, guestCA]);

  guestClaimArrayNew := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('guest claim includes data without block', guestClaimArrayNew, guestClaimArray);
END $$;
ROLLBACK TO SAVEPOINT guest_claim_array;

SAVEPOINT guest_claim_array_block;
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
  guestClaimArray UUID[];
  guestClaimArrayNew UUID[];
  rec RECORD;
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

  PERFORM vibetype_test.invoker_set(accountC);

  FOR rec IN
    SELECT * FROM vibetype.create_guests(eventC, ARRAY[contactCA, contactCB])
  LOOP
    IF rec.contact_id = contactCA THEN
      guestCA := rec.id;
    ELSIF rec.contact_id = contactCB THEN
      guestCB := rec.id;
    END IF;
  END LOOP;

  PERFORM vibetype_test.invoker_set_empty();

  guestClaimArray := vibetype_test.guest_claim_from_account_guest(accountA);

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  guestClaimArrayNew := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('guest claim excludes blocked data', guestClaimArrayNew, ARRAY[guestCA]);
END $$;
ROLLBACK TO SAVEPOINT guest_claim_array_block;

SAVEPOINT guest_claim_array_none;
DO $$
DECLARE
  guestClaimArray UUID[];
BEGIN
  guestClaimArray := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('guest claim array is initially unset', guestClaimArray, ARRAY[]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT guest_claim_array_none;

ROLLBACK;
