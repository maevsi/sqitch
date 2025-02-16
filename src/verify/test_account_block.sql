BEGIN;

DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;

  contactAA UUID;
  contactBB UUID;
  contactCC UUID;

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

  -- remove accounts (if exist)

  PERFORM maevsi_test.account_remove('a');
  PERFORM maevsi_test.account_remove('b');
  PERFORM maevsi_test.account_remove('c');

  -- fill with test data

  accountA := maevsi_test.account_create('a', 'a@example.com');
  accountB := maevsi_test.account_create('b', 'b@example.com');
  accountC := maevsi_test.account_create('c', 'c@example.com');

  contactAA := maevsi_test.contact_select_by_account_id(accountA);
  contactBB := maevsi_test.contact_select_by_account_id(accountB);
  contactCC := maevsi_test.contact_select_by_account_id(accountC);

  contactAB := maevsi_test.contact_create(accountA, 'b@example.com');
  contactAC := maevsi_test.contact_create(accountA, 'c@example.com');
  contactBA := maevsi_test.contact_create(accountB, 'a@example.com');
  contactBC := maevsi_test.contact_create(accountB, 'c@example.com');
  contactCA := maevsi_test.contact_create(accountC, 'a@example.com');
  contactCB := maevsi_test.contact_create(accountC, 'b@example.com');

  eventA := maevsi_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := maevsi_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := maevsi_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM maevsi_test.event_category_create('category');
  PERFORM maevsi_test.event_category_mapping_create(accountA, eventA, 'category');
  PERFORM maevsi_test.event_category_mapping_create(accountB, eventB, 'category');
  PERFORM maevsi_test.event_category_mapping_create(accountC, eventC, 'category');

  guestAB := maevsi_test.guest_create(accountA, eventA, contactAB);
  guestAC := maevsi_test.guest_create(accountA, eventA, contactAC);
  guestBA := maevsi_test.guest_create(accountB, eventB, contactBA);
  guestBC := maevsi_test.guest_create(accountB, eventB, contactBC);

  -- add guests for `eventC` using function `maevsi.create_guests`

  PERFORM maevsi_test.invoker_set(accountC);

  FOR rec IN
    SELECT * FROM maevsi.create_guests(eventC, ARRAY[contactCA, contactCB])
  LOOP
    IF rec.contact_id = contactCA THEN
      guestCA := rec.id;
    ELSIF rec.contact_id = contactCB THEN
      guestCB := rec.id;
    END IF;
  END LOOP;

  PERFORM maevsi_test.invoker_unset();

  -- run tests

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_test('event: no block, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.event_test('event: no block, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.event_test('event: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.event_test('event: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: no block, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: no block, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.contact_test('contact: no block, perspective A', accountA, ARRAY[contactAA, contactAB, contactAC, contactBA, contactCA]::UUID[]);
  PERFORM maevsi_test.contact_test('contact: no block, perspective B', accountB, ARRAY[contactBB, contactBA, contactBC, contactAB, contactCB]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.contact_test('contact: A blocks B, perspective A', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM maevsi_test.contact_test('contact: A blocks B, perspective B', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.guest_test('guest: no block, perspective A', accountA, ARRAY[guestAB, guestAC, guestBA, guestCA]::UUID[]);
  PERFORM maevsi_test.guest_test('guest: no block, perspective B', accountB, ARRAY[guestBA, guestBC, guestAB, guestCB]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.guest_test('guest: A blocks B, perspective A', accountA, ARRAY[guestAC, guestCA]::UUID[]);
  PERFORM maevsi_test.guest_test('guest: A blocks B, perspective B', accountB, ARRAY[guestBC, guestCB]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_test('anonymous login: no block, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.contact_test('anonymous login: no block, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.guest_test('anonymous login: no block, guests', null, ARRAY[]::UUID[]);

  PERFORM maevsi_test.event_test('anonymous login: A blocks B, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.contact_test('anonymous login: A blocks B, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.guest_test('anonymous login: A blocks B, guests', null, ARRAY[]::UUID[]);

  -- tests for function `guest_claim_array()`

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  guestClaimArray := maevsi.guest_claim_array();
  PERFORM maevsi_test.uuid_array_test('no block, guest claim is unset', guestClaimArray, ARRAY[]::UUID[]);

  guestClaimArray := maevsi_test.guest_claim_from_account_guest(accountA);
  PERFORM maevsi_test.uuid_array_test('no block, guest claim was added', guestClaimArray, ARRAY[guestBA, guestCA]);

  guestClaimArrayNew := maevsi.guest_claim_array();
  PERFORM maevsi_test.uuid_array_test('no block, guest claim includes data', guestClaimArrayNew, guestClaimArray);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  guestClaimArrayNew := maevsi.guest_claim_array();
  PERFORM maevsi_test.uuid_array_test('A blocks B, guest claim excludes blocked data', guestClaimArrayNew, ARRAY[guestCA]);
END $$;

ROLLBACK;
