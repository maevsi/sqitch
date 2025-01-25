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

  invitationAB UUID;
  invitationAC UUID;
  invitationBA UUID;
  invitationBC UUID;
  invitationCA UUID;
  invitationCB UUID;

  invitationClaimArray UUID[];
  invitationClaimArrayNew UUID[];

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

  invitationAB := maevsi_test.invitation_create(accountA, eventA, contactAB);
  invitationAC := maevsi_test.invitation_create(accountA, eventA, contactAC);
  invitationBA := maevsi_test.invitation_create(accountB, eventB, contactBA);
  invitationBC := maevsi_test.invitation_create(accountB, eventB, contactBC);
  invitationCA := maevsi_test.invitation_create(accountC, eventC, contactCA);
  invitationCB := maevsi_test.invitation_create(accountC, eventC, contactCB);

  -- run tests

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_test('event: no blocking, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.event_test('event: no blocking, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.event_test('event: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.event_test('event: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: no blocking, perspective A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: no blocking, perspective B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.event_category_mapping_test('event_category_mapping: A blocks B, perspective B', accountB, ARRAY[eventB, eventC]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.contact_test('contact: no blocking, perspective A', accountA, ARRAY[contactAA, contactAB, contactAC, contactBA, contactCA]::UUID[]);
  PERFORM maevsi_test.contact_test('contact: no blocking, perspective B', accountB, ARRAY[contactBB, contactBA, contactBC, contactAB, contactCB]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.contact_test('contact: A blocks B, perspective A', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM maevsi_test.contact_test('contact: A blocks B, perspective B', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.invitation_test('invitation: no blocking, perspective A', accountA, ARRAY[invitationAB, invitationAC, invitationBA, invitationCA]::UUID[]);
  PERFORM maevsi_test.invitation_test('invitation: no blocking, perspective B', accountB, ARRAY[invitationBA, invitationBC, invitationAB, invitationCB]::UUID[]);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  PERFORM maevsi_test.invitation_test('invitation: A blocks B, perspective A', accountA, ARRAY[invitationAC, invitationCA]::UUID[]);
  PERFORM maevsi_test.invitation_test('invitation: A blocks B, perspective B', accountB, ARRAY[invitationBC, invitationCB]::UUID[]);

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  PERFORM maevsi_test.event_test('anonymous login: no blocking, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.contact_test('anonymous login: no blocking, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.invitation_test('anonymous login: no blocking, invitations', null, ARRAY[]::UUID[]);

  PERFORM maevsi_test.event_test('anonymous login: A blocks B, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.contact_test('anonymous login: A blocks B, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.invitation_test('anonymous login: A blocks B, invitations', null, ARRAY[]::UUID[]);

  -- tests for function `invitation_claim_array()`

  PERFORM maevsi_test.account_block_remove(accountA, accountB);
  invitationClaimArray := maevsi.invitation_claim_array();
  PERFORM maevsi_test.uuid_array_test('no blocking, invitation claim is unset', invitationClaimArray, ARRAY[]::UUID[]);

  invitationClaimArray := maevsi_test.invitation_claim_from_account_invitation(accountA);
  PERFORM maevsi_test.uuid_array_test('no blocking, invitation claim was added', invitationClaimArray, ARRAY[invitationBA, invitationCA]);

  invitationClaimArrayNew := maevsi.invitation_claim_array();
  PERFORM maevsi_test.uuid_array_test('no blocking, invitation claim includes data', invitationClaimArrayNew, invitationClaimArray);

  PERFORM maevsi_test.account_block_create(accountA, accountB);
  invitationClaimArrayNew := maevsi.invitation_claim_array();
  PERFORM maevsi_test.uuid_array_test('A blocks B, invitation claim excludes blocked data', invitationClaimArrayNew, ARRAY[invitationCA]);
END $$;

ROLLBACK;
