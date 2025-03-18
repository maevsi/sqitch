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

BEGIN

  -- remove accounts (if exist)

  PERFORM vibetype_test.account_remove('a');
  PERFORM vibetype_test.account_remove('b');
  PERFORM vibetype_test.account_remove('c');

  -- fill with test data

  accountA := vibetype_test.account_create('a', 'a@example.com');
  accountB := vibetype_test.account_create('b', 'b@example.com');
  accountC := vibetype_test.account_create('c', 'c@example.com');

  contactAA := vibetype_test.contact_select_by_account_id(accountA);
  contactBB := vibetype_test.contact_select_by_account_id(accountB);
  contactCC := vibetype_test.contact_select_by_account_id(accountC);

  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  contactBC := vibetype_test.contact_create(accountB, 'c@example.com');
  contactCA := vibetype_test.contact_create(accountC, 'a@example.com');
  contactCB := vibetype_test.contact_create(accountC, 'b@example.com');

  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  eventB := vibetype_test.event_create(accountB, 'Event by B', 'event-by-b', '2025-06-01 20:00', 'public');
  eventC := vibetype_test.event_create(accountC, 'Event by C', 'event-by-c', '2025-06-01 20:00', 'public');

  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_category_mapping_create(accountA, eventA, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountB, eventB, 'category');
  PERFORM vibetype_test.event_category_mapping_create(accountC, eventC, 'category');

  guestAB := vibetype_test.guest_create(accountA, eventA, contactAB);
  guestAC := vibetype_test.guest_create(accountA, eventA, contactAC);
  guestBA := vibetype_test.guest_create(accountB, eventB, contactBA);
  guestBC := vibetype_test.guest_create(accountB, eventB, contactBC);
  guestCA := vibetype_test.guest_create(accountC, eventC, contactCA);
  guestCB := vibetype_test.guest_create(accountC, eventC, contactCB);

  -- run tests

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  PERFORM vibetype_test.event_test('event: no blocking, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.event_test('event: no blocking, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.event_test('event: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM vibetype_test.event_test('event: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping: no blocking, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping: no blocking, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM vibetype_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  PERFORM vibetype_test.contact_test('contact: no blocking, perspective A', accountA, ARRAY[contactAA, contactAB, contactAC, contactBA, contactCA]::UUID[]);
  PERFORM vibetype_test.contact_test('contact: no blocking, perspective B', accountB, ARRAY[contactBB, contactBA, contactBC, contactAB, contactCB]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.contact_test('contact: A blocks B, perspective A', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM vibetype_test.contact_test('contact: A blocks B, perspective B', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  PERFORM vibetype_test.guest_test('guest: no blocking, perspective A', accountA, ARRAY[guestAB, guestAC, guestBA, guestCA]::UUID[]);
  PERFORM vibetype_test.guest_test('guest: no blocking, perspective B', accountB, ARRAY[guestBA, guestBC, guestAB, guestCB]::UUID[]);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.guest_test('guest: A blocks B, perspective A', accountA, ARRAY[guestAC, guestCA]::UUID[]);
  PERFORM vibetype_test.guest_test('guest: A blocks B, perspective B', accountB, ARRAY[guestBC, guestCB]::UUID[]);

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  PERFORM vibetype_test.event_test('anonymous login: no blocking, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.contact_test('anonymous login: no blocking, contacts', null, ARRAY[]::UUID[]);
  PERFORM vibetype_test.guest_test('anonymous login: no blocking, guests', null, ARRAY[]::UUID[]);

  PERFORM vibetype_test.event_test('anonymous login: A blocks B, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM vibetype_test.contact_test('anonymous login: A blocks B, contacts', null, ARRAY[]::UUID[]);
  PERFORM vibetype_test.guest_test('anonymous login: A blocks B, guests', null, ARRAY[]::UUID[]);

  -- tests for function `guest_claim_array()`

  PERFORM vibetype_test.account_block_remove(accountA, accountB);
  guestClaimArray := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('no blocking, guest claim is unset', guestClaimArray, ARRAY[]::UUID[]);

  guestClaimArray := vibetype_test.guest_claim_from_account_guest(accountA);
  PERFORM vibetype_test.uuid_array_test('no blocking, guest claim was added', guestClaimArray, ARRAY[guestBA, guestCA]);

  guestClaimArrayNew := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('no blocking, guest claim includes data', guestClaimArrayNew, guestClaimArray);

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  guestClaimArrayNew := vibetype.guest_claim_array();
  PERFORM vibetype_test.uuid_array_test('A blocks B, guest claim excludes blocked data', guestClaimArrayNew, ARRAY[guestCA]);
END $$;

ROLLBACK;
