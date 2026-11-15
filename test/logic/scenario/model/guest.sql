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
  PERFORM vibetype_test.guest_test('anonymous sees no guest', NULL, ARRAY[]::UUID[]);

  PERFORM set_config('jwt.claims.guests', '["' || guestAB || '"]', true);
  PERFORM vibetype_test.guest_test('anonymous sees a claimed guest', NULL, ARRAY[guestAB]::UUID[]);
  PERFORM set_config('jwt.claims.guests', '', true);
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

SAVEPOINT guest_select_contact_without_account;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactAB UUID;
  contactAX UUID;
  eventA UUID;
  guestAB UUID;
  guestAX UUID;
  _count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAX := vibetype_test.contact_create(accountA, 'x@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAX := vibetype_test.guest_create(accountA, eventA, contactAX);

  -- A non-empty block list makes `NULL = ANY (blocked)` evaluate to NULL, so contacts without an account need their own guard.
  PERFORM vibetype_test.account_block_create(accountC, accountA);
  PERFORM vibetype_test.guest_test('organizer sees guests of contacts without an account', accountA, ARRAY[guestAB, guestAX]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountB, accountA);
  PERFORM vibetype_test.guest_test('organizer does not see guests of a blocking account', accountA, ARRAY[guestAX]::UUID[]);
  PERFORM vibetype_test.guest_test('blocking account does not see guests through the blocked organizer', accountB, ARRAY[]::UUID[]);

  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.guest SET feedback = 'accepted' WHERE id IN (guestAB, guestAX);
  GET DIAGNOSTICS _count = ROW_COUNT;

  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed: organizer should update exactly the visible guest, but updated % guests', _count;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT guest_select_contact_without_account;

ROLLBACK;
