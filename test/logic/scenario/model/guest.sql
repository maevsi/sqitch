\echo test_guest...

BEGIN;

SAVEPOINT guest_create_block;
DO $$
DECLARE
  accountC UUID;
  accountB UUID;
  contactCA UUID;
  contactCB UUID;
  eventC UUID;
BEGIN
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.account_block_create(accountC, accountB);

  BEGIN
    PERFORM vibetype_test.invoker_set(accountC);
    PERFORM vibetype.create_guests(eventC, ARRAY[contactCA, contactCB]);
    PERFORM vibetype_test.invoker_set_previous();
    RAISE EXCEPTION 'Test failed: User should not be able to add users as guests if one of the users is blocked';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_create_block;

SAVEPOINT guest_create_block_test;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  contactAB UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  BEGIN
    PERFORM vibetype_test.guest_create(accountA, eventA, contactAB);
    RAISE EXCEPTION 'Test failed: User should not be able to add a blocked user as a guest';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT guest_create_block_test;

SAVEPOINT guest_select;
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

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.guest_test('guest visibility without block (perspective A)', accountA, ARRAY[guestAB, guestAC, guestBA, guestCA]::UUID[]);
  PERFORM vibetype_test.guest_test('guest visibility without block (perspective B)', accountB, ARRAY[guestBA, guestBC, guestAB, guestCB]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT guest_select;

SAVEPOINT guest_select_block;
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

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.guest_test('guest visibility with block (perspective A)', accountA, ARRAY[guestAC, guestCA]::UUID[]);
  PERFORM vibetype_test.guest_test('guest visibility with block (perspective B)', accountB, ARRAY[guestBC, guestCB]::UUID[]);
END $$;
ROLLBACK TO SAVEPOINT guest_select_block;

ROLLBACK;
