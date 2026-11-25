\echo test_contact_merge...

BEGIN;

SAVEPOINT contact_merge_success;
DO $$
DECLARE
  _attendance_contact_id UUID;
  _contact vibetype.contact;
  _group_ids UUID[];
  _guest_contact_id UUID;
  _result vibetype.contact;
  accountA UUID;
  attendanceId UUID;
  contactKept UUID;
  contactMerged UUID;
  eventA UUID;
  groupBoth UUID;
  groupMerged UUID;
  guestMerged UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  contactKept := vibetype_test.contact_create(accountA, 'kept@example.com');
  contactMerged := vibetype_test.contact_create(accountA, 'merged@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  guestMerged := vibetype_test.guest_create(accountA, eventA, contactMerged);

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.attendance(guest_id, contact_id) VALUES (guestMerged, contactMerged) RETURNING id INTO attendanceId;
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Both') RETURNING id INTO groupBoth;
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Merged') RETURNING id INTO groupMerged;
  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (groupBoth, contactKept), (groupBoth, contactMerged), (groupMerged, contactMerged);

  SELECT * INTO _contact FROM vibetype.contact WHERE id = contactKept;
  _contact.email_addresses := ARRAY['kept@example.com', 'merged@example.com'];
  _contact.first_name := 'Merged';

  _result := vibetype.contact_merge(contactKept, contactMerged, _contact);

  IF _result.id <> contactKept OR _result.email_addresses <> ARRAY['kept@example.com', 'merged@example.com']::vibetype.email_address[] OR _result.first_name <> 'Merged' THEN
    RAISE EXCEPTION 'Test failed (contact_merge_success): the kept contact did not take the given values: %', _result;
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype.contact WHERE id = contactMerged) THEN
    RAISE EXCEPTION 'Test failed (contact_merge_success): the merged contact still exists';
  END IF;

  SELECT contact_id INTO _guest_contact_id FROM vibetype.guest WHERE id = guestMerged;
  IF _guest_contact_id IS DISTINCT FROM contactKept THEN
    RAISE EXCEPTION 'Test failed (contact_merge_success): the guest did not move to the kept contact, its contact is %', _guest_contact_id;
  END IF;

  SELECT contact_id INTO _attendance_contact_id FROM vibetype.attendance WHERE id = attendanceId;
  IF _attendance_contact_id IS DISTINCT FROM contactKept THEN
    RAISE EXCEPTION 'Test failed (contact_merge_success): the attendance did not move to the kept contact, its contact is %', _attendance_contact_id;
  END IF;

  SELECT array_agg(contact_group_id ORDER BY contact_group_id) INTO _group_ids FROM vibetype.contact_group_member WHERE contact_id = contactKept;
  IF _group_ids IS DISTINCT FROM (SELECT array_agg(id ORDER BY id) FROM unnest(ARRAY[groupBoth, groupMerged]) AS id) THEN
    RAISE EXCEPTION 'Test failed (contact_merge_success): the kept contact is in groups % instead of both', _group_ids;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_merge_success;

SAVEPOINT contact_merge_account;
DO $$
DECLARE
  _contact vibetype.contact;
  _result vibetype.contact;
  accountA UUID;
  accountB UUID;
  contactKept UUID;
  contactMerged UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactKept := vibetype_test.contact_create(accountA, 'kept@example.com');
  contactMerged := vibetype_test.contact_create(accountA, 'b@example.com');

  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_account_dropped', accountA, contactKept, contactMerged, 'VTCMV');

  PERFORM vibetype_test.invoker_set(accountA);

  SELECT * INTO _contact FROM vibetype.contact WHERE id = contactKept;
  _contact.account_id := accountB;

  _result := vibetype.contact_merge(contactKept, contactMerged, _contact);

  IF _result.account_id IS DISTINCT FROM accountB THEN
    RAISE EXCEPTION 'Test failed (contact_merge_account): the kept contact did not take over the merged contact''s account, it is %', _result.account_id;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_merge_account;

SAVEPOINT contact_merge_rejected;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  accountC UUID;
  contactA UUID;
  contactAB UUID;
  contactAC UUID;
  contactAD UUID;
  contactAE UUID;
  contactBA UUID;
  eventA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  accountC := vibetype_test.account_registration_verified('c', 'c@example.com');
  contactA := vibetype_test.contact_select_by_account_id(accountA);
  contactAB := vibetype_test.contact_create(accountA, 'b@example.com');
  contactAC := vibetype_test.contact_create(accountA, 'c@example.com');
  contactAD := vibetype_test.contact_create(accountA, 'd@example.com');
  contactAE := vibetype_test.contact_create(accountA, 'e@example.com');
  contactBA := vibetype_test.contact_create(accountB, 'a@example.com');
  eventA := vibetype_test.event_create(accountA, 'Event by A', 'event-by-a', '2025-06-01 20:00', 'public');
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAD);
  PERFORM vibetype_test.guest_create(accountA, eventA, contactAE);

  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_same', accountA, contactAD, contactAD, 'VTCMN');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_foreign_kept', accountA, contactBA, contactAD, 'VTCMN');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_foreign_merged', accountA, contactAD, contactBA, 'VTCMN');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_own_kept', accountA, contactA, contactAD, 'VTCMS');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_own_merged', accountA, contactAD, contactA, 'VTCMS');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_accounts', accountA, contactAB, contactAC, 'VTCMA');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_same_event', accountA, contactAD, contactAE, 'VTCMG');
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_anonymous', NULL, contactAD, contactAE, '42501');

  PERFORM vibetype_test.account_block_create(accountA, accountB);
  PERFORM vibetype_test.contact_merge_rejected_test('contact_merge_blocked', accountA, contactAD, contactAB, 'VTCMN');
END $$;
ROLLBACK TO SAVEPOINT contact_merge_rejected;

ROLLBACK;
