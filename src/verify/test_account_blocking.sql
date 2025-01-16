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

  test_case TEXT;

BEGIN

  -- remove accounts (if exist)

  PERFORM maevsi_test.remove_account('ameier');
  PERFORM maevsi_test.remove_account('bschulze');
  PERFORM maevsi_test.remove_account('cmueller');

  -- fill with test data

  accountA := maevsi_test.create_account('ameier', 'anton.meier@abc.de');
  accountB := maevsi_test.create_account('bschulze', 'berta.schulze@abc.de');
  accountC := maevsi_test.create_account('cmueller', 'chris.mueller@abc.de');

  contactAA := maevsi_test.get_own_contact(accountA);
  contactBB := maevsi_test.get_own_contact(accountB);
  contactCC := maevsi_test.get_own_contact(accountC);

  contactAB := maevsi_test.create_contact(accountA, 'berta.schulze@abc.de');
  contactAC := maevsi_test.create_contact(accountA, 'chris.mueller@abc.de');
  contactBA := maevsi_test.create_contact(accountB, 'anton.meier@abc.de');
  contactBC := maevsi_test.create_contact(accountB, 'chris.mueller@abc.de');
  contactCA := maevsi_test.create_contact(accountC, 'anton.meier@abc.de');
  contactCB := maevsi_test.create_contact(accountC, 'berta.schulze@abc.de');

  eventA := maevsi_test.create_event(accountA, 'Event A', 'event-a', '2025-06-01 20:00', 'public');
  eventB := maevsi_test.create_event(accountB, 'Event B', 'event-b', '2025-06-01 20:00', 'public');
  eventC := maevsi_test.create_event(accountC, 'Event C', 'event-c', '2025-06-01 20:00', 'public');

  PERFORM maevsi_test.create_event_category('concert');
  PERFORM maevsi_test.create_event_category_mapping(accountA, eventA, 'concert');
  PERFORM maevsi_test.create_event_category_mapping(accountB, eventB, 'concert');
  PERFORM maevsi_test.create_event_category_mapping(accountC, eventC, 'concert');

  invitationAB := maevsi_test.create_invitation(accountA, eventA, contactAB);
  invitationAC := maevsi_test.create_invitation(accountA, eventA, contactAC);
  invitationBA := maevsi_test.create_invitation(accountB, eventB, contactBA);
  invitationBC := maevsi_test.create_invitation(accountB, eventB, contactBC);
  invitationCA := maevsi_test.create_invitation(accountC, eventC, contactCA);
  invitationCB := maevsi_test.create_invitation(accountC, eventC, contactCB);

  -- run tests

  test_case := 'test 1';
  RAISE NOTICE '%: no blocking, test events', test_case;

  PERFORM maevsi_test.unblock_account(accountA, accountB);

  PERFORM maevsi_test.select_events(test_case, 'A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.select_events(test_case, 'B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  test_case := 'test 2';
  RAISE NOTICE '%: A blocks B, test events', test_case;

  PERFORM maevsi_test.block_account(accountA, accountB);

  PERFORM maevsi_test.select_events(test_case, 'A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.select_events(test_case, 'B', accountB, ARRAY[eventB, eventC]::UUID[]);

  test_case := 'test 3';
  RAISE NOTICE '%: no blocking, test event_category_mapping', test_case;

  PERFORM maevsi_test.unblock_account(accountA, accountB);

  PERFORM maevsi_test.select_event_category_mappings(test_case, 'A', accountA, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.select_event_category_mappings(test_case, 'B', accountB, ARRAY[eventA, eventB, eventC]::UUID[]);

  test_case := 'test 4';
  RAISE NOTICE '%: A blocks B, test event_category_mapping', test_case;

  PERFORM maevsi_test.block_account(accountA, accountB);

  PERFORM maevsi_test.select_event_category_mappings(test_case, 'A', accountA, ARRAY[eventA, eventC]::UUID[]);
  PERFORM maevsi_test.select_event_category_mappings(test_case, 'B', accountB, ARRAY[eventB, eventC]::UUID[]);

  RAISE NOTICE 'contactAA = %', contactAA;
  RAISE NOTICE 'contactBB = %', contactBB;
  RAISE NOTICE 'contactCC = %', contactCC;
  RAISE NOTICE 'contactAB = %', contactAB;
  RAISE NOTICE 'contactAC = %', contactAC;
  RAISE NOTICE 'contactBA = %', contactBA;
  RAISE NOTICE 'contactBC = %', contactBC;
  RAISE NOTICE 'contactCA = %', contactCA;
  RAISE NOTICE 'contactCB = %', contactCB;

  test_case := 'test 5';
  RAISE NOTICE '%: no blocking, test contacts', test_case;

  PERFORM maevsi_test.unblock_account(accountA, accountB);

  PERFORM maevsi_test.select_contacts(test_case, 'A', accountA, ARRAY[contactAA, contactAB, contactAC, contactBA, contactCA]::UUID[]);
  PERFORM maevsi_test.select_contacts(test_case, 'B', accountB, ARRAY[contactBB, contactBA, contactBC, contactAB, contactCB]::UUID[]);

  test_case := 'test 6';
  RAISE NOTICE '%: A blocks B, test contacts', test_case;

  PERFORM maevsi_test.block_account(accountA, accountB);

  PERFORM maevsi_test.select_contacts(test_case, 'A', accountA, ARRAY[contactAA, contactAC, contactCA]::UUID[]);
  PERFORM maevsi_test.select_contacts(test_case, 'B', accountB, ARRAY[contactBB, contactBC, contactCB]::UUID[]);

  test_case := 'test 7';
  RAISE NOTICE '%: no blocking, test invitations', test_case;

  PERFORM maevsi_test.unblock_account(accountA, accountB);

  PERFORM maevsi_test.select_invitations(test_case, 'A', accountA, ARRAY[invitationAB, invitationAC, invitationBA, invitationCA]::UUID[]);
  PERFORM maevsi_test.select_invitations(test_case, 'B', accountB, ARRAY[invitationBA, invitationBC, invitationAB, invitationCB]::UUID[]);

  test_case := 'test 8';
  RAISE NOTICE '%: A blocks B, test invitations', test_case;

  PERFORM maevsi_test.block_account(accountA, accountB);

  PERFORM maevsi_test.select_invitations(test_case, 'A', accountA, ARRAY[invitationAC, invitationCA]::UUID[]);
  PERFORM maevsi_test.select_invitations(test_case, 'B', accountB, ARRAY[invitationBC, invitationCB]::UUID[]);

  -- tests for anonymous login

  test_case := 'test 9';
  RAISE NOTICE '%: no blocking, anonymous login', test_case;

  PERFORM maevsi_test.unblock_account(accountA, accountB);

  PERFORM maevsi_test.select_events(test_case, 'anonymous, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.select_contacts(test_case, 'anonymous, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.select_invitations(test_case, 'anonymous, invitations', null, ARRAY[]::UUID[]);

  test_case := 'test 10';
  RAISE NOTICE '%: A blocks B, anonymous login', test_case;

  PERFORM maevsi_test.select_events(test_case, 'anonymous, events', null, ARRAY[eventA, eventB, eventC]::UUID[]);
  PERFORM maevsi_test.select_contacts(test_case, 'anonymous, contacts', null, ARRAY[]::UUID[]);
  PERFORM maevsi_test.select_invitations(test_case, 'anonymous, invitations', null, ARRAY[]::UUID[]);

  -- tests completed successfully

  RAISE NOTICE 'tests OK';

END $$;

ROLLBACK;
