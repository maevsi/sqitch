\echo test_contact_group...

BEGIN;

SAVEPOINT contact_group_owner;
DO $$
DECLARE
  _count INTEGER;
  _group_id UUID;
  _name TEXT;
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues') RETURNING id INTO _group_id;

  UPDATE vibetype.contact_group SET name = 'Work' WHERE id = _group_id;

  SELECT name INTO _name FROM vibetype.contact_group WHERE id = _group_id;
  IF _name IS DISTINCT FROM 'Work' THEN
    RAISE EXCEPTION 'Test failed (contact_group_owner): the owner could not rename the group, name is %', _name;
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact_group;
  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed (contact_group_owner): the owner lists % groups instead of 1', _count;
  END IF;

  DELETE FROM vibetype.contact_group WHERE id = _group_id;

  SELECT count(*) INTO _count FROM vibetype.contact_group;
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_owner): the owner could not delete the group';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_owner;

SAVEPOINT contact_group_anonymous;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues');
    RAISE EXCEPTION 'Test failed (contact_group_anonymous): an anonymous invoker created a group';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_anonymous;

SAVEPOINT contact_group_foreign_account;
DO $$
DECLARE
  _count INTEGER;
  _group_id UUID;
  _name TEXT;
  accountA UUID;
  accountB UUID;
  contactA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactA := vibetype_test.contact_create(accountA, 'c@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues') RETURNING id INTO _group_id;
  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_id, contactA);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);

  SELECT count(*) INTO _count FROM vibetype.contact_group;
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_foreign_account): another account sees a group';
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact_group_member;
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_foreign_account): another account sees a membership';
  END IF;

  UPDATE vibetype.contact_group SET name = 'Taken' WHERE id = _group_id;
  DELETE FROM vibetype.contact_group WHERE id = _group_id;
  DELETE FROM vibetype.contact_group_member WHERE contact_group_id = _group_id;

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set(accountA);

  SELECT name INTO _name FROM vibetype.contact_group WHERE id = _group_id;
  IF _name IS DISTINCT FROM 'Colleagues' THEN
    RAISE EXCEPTION 'Test failed (contact_group_foreign_account): another account renamed or deleted the group';
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact_group_member WHERE contact_group_id = _group_id;
  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed (contact_group_foreign_account): another account deleted the membership';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_foreign_account;

SAVEPOINT contact_group_name_empty;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, '');
    RAISE EXCEPTION 'Test failed (contact_group_name_empty): an empty name was accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_name_empty;

SAVEPOINT contact_group_name_length;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, repeat('a', 100));

  BEGIN
    INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, repeat('b', 101));
    RAISE EXCEPTION 'Test failed (contact_group_name_length): a name of 101 characters was accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_name_length;

SAVEPOINT contact_group_name_duplicate;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues');

  BEGIN
    INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'colleagues');
    RAISE EXCEPTION 'Test failed (contact_group_name_duplicate): a case-only duplicate was accepted';
  EXCEPTION
    WHEN unique_violation THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountB, 'Colleagues');
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_name_duplicate;

SAVEPOINT contact_group_member_foreign;
DO $$
DECLARE
  _group_a UUID;
  accountA UUID;
  accountB UUID;
  contactA UUID;
  contactB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactA := vibetype_test.contact_create(accountA, 'c@example.com');
  contactB := vibetype_test.contact_create(accountB, 'c@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues') RETURNING id INTO _group_a;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  BEGIN
    INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_a, contactB);
    RAISE EXCEPTION 'Test failed (contact_group_member_foreign): a membership in another account''s group was accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  BEGIN
    INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_a, contactB);
    RAISE EXCEPTION 'Test failed (contact_group_member_foreign): a membership of another account''s contact was accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_a, contactA);
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_member_foreign;

SAVEPOINT contact_group_member_cascade;
DO $$
DECLARE
  _count INTEGER;
  _group_a UUID;
  _group_b UUID;
  _group_c UUID;
  accountA UUID;
  accountB UUID;
  contactA UUID;
  contactA2 UUID;
  contactB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactA := vibetype_test.contact_create(accountA, 'c@example.com');
  contactA2 := vibetype_test.contact_create(accountA, 'd@example.com');
  contactB := vibetype_test.contact_create(accountB, 'e@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'One') RETURNING id INTO _group_a;
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Two') RETURNING id INTO _group_b;
  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_a, contactA), (_group_a, contactA2), (_group_b, contactA2);
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountB, 'Three') RETURNING id INTO _group_c;
  INSERT INTO vibetype.contact_group_member(contact_group_id, contact_id) VALUES (_group_c, contactB);
  PERFORM vibetype_test.invoker_set_previous();

  -- deleting a group keeps its contacts
  PERFORM vibetype_test.invoker_set(accountA);
  DELETE FROM vibetype.contact_group WHERE id = _group_a;
  SELECT count(*) INTO _count FROM vibetype.contact WHERE id IN (contactA, contactA2);
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_cascade): deleting a group deleted contacts';
  END IF;
  SELECT count(*) INTO _count FROM vibetype.contact_group_member WHERE contact_group_id = _group_a;
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_cascade): deleting a group kept its memberships';
  END IF;

  -- deleting a contact removes its memberships
  DELETE FROM vibetype.contact WHERE id = contactA2;
  SELECT count(*) INTO _count FROM vibetype.contact_group_member WHERE contact_id = contactA2;
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_cascade): deleting a contact kept its memberships';
  END IF;
  PERFORM vibetype_test.invoker_set_previous();

  -- deleting an account removes its groups and memberships
  PERFORM vibetype_test.invoker_set(accountB);
  PERFORM vibetype.account_delete('password');
  PERFORM vibetype_test.invoker_set_previous();

  -- the policies hide rows of a deleted account from every invoker, so the foreign keys are checked instead
  SELECT count(*) INTO _count
  FROM pg_catalog.pg_constraint
  WHERE contype = 'f'
    AND conrelid IN ('vibetype.contact_group'::regclass, 'vibetype.contact_group_member'::regclass)
    AND confdeltype <> 'c';
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_cascade): % foreign keys do not cascade', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_group_member_cascade;

SAVEPOINT contact_create_multiple;
DO $$
DECLARE
  _count INTEGER;
  _created_by_other INTEGER;
  accountA UUID;
  accountB UUID;
  _foreign_id UUID := gen_random_uuid();
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  SELECT count(*) INTO _count
  FROM vibetype.create_contacts(ARRAY[
    jsonb_populate_record(NULL::vibetype.contact, jsonb_build_object('email_addresses', jsonb_build_array('c@example.com'), 'first_name', 'C', 'created_by', accountB, 'id', _foreign_id)),
    jsonb_populate_record(NULL::vibetype.contact, jsonb_build_object('email_addresses', jsonb_build_array('d@example.com')))
  ]);
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_create_multiple): % contacts created instead of 2', _count;
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact WHERE created_by = accountA AND email_addresses[1] IN ('c@example.com', 'd@example.com');
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_create_multiple): the contacts are not owned by the invoker';
  END IF;

  IF EXISTS (SELECT 1 FROM vibetype.contact WHERE id = _foreign_id) THEN
    RAISE EXCEPTION 'Test failed (contact_create_multiple): the passed id was used';
  END IF;

  PERFORM vibetype_test.invoker_set_previous();

  SELECT count(*) INTO _created_by_other FROM vibetype.contact WHERE created_by = accountB AND email_addresses[1] IN ('c@example.com', 'd@example.com');
  IF _created_by_other <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_create_multiple): the passed created_by was used';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT contact_create_multiple;

SAVEPOINT contact_create_multiple_atomic;
DO $$
DECLARE
  _count INTEGER;
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    PERFORM vibetype.create_contacts(ARRAY[
      jsonb_populate_record(NULL::vibetype.contact, jsonb_build_object('email_addresses', jsonb_build_array('c@example.com'))),
      jsonb_populate_record(NULL::vibetype.contact, jsonb_build_object('email_addresses', jsonb_build_array('d@example.com'), 'phone_number', 'invalid'))
    ]);
    RAISE EXCEPTION 'Test failed (contact_create_multiple_atomic): a row violating a check was accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;

  SELECT count(*) INTO _count FROM vibetype.contact WHERE email_addresses[1] IN ('c@example.com', 'd@example.com');
  IF _count <> 0 THEN
    RAISE EXCEPTION 'Test failed (contact_create_multiple_atomic): % contacts were inserted despite a failing row', _count;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_create_multiple_atomic;

SAVEPOINT contact_group_create_multiple;
DO $$
DECLARE
  _count INTEGER;
  _ids_before UUID[];
  _ids_after UUID[];
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountB, 'colleagues');
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Colleagues');
  _ids_before := ARRAY(SELECT id FROM vibetype.contact_group);

  SELECT count(*) INTO _count FROM vibetype.create_contact_groups(ARRAY['COLLEAGUES', 'University', 'university']);
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple): % groups returned instead of 2', _count;
  END IF;

  _ids_after := ARRAY(SELECT id FROM vibetype.contact_group WHERE lower(name) = 'colleagues');
  IF _ids_after IS DISTINCT FROM _ids_before THEN
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple): the existing group was replaced';
  END IF;

  IF NOT (_ids_before <@ ARRAY(SELECT id FROM vibetype.create_contact_groups(ARRAY['colleagues']))) THEN
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple): the existing group was not returned';
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact_group;
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple): % groups exist instead of 2', _count;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();

  -- the other account's group of the same name was neither returned nor changed
  PERFORM vibetype_test.invoker_set(accountB);
  SELECT count(*) INTO _count FROM vibetype.contact_group;
  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple): the other account has % groups instead of 1', _count;
  END IF;
  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_create_multiple;

SAVEPOINT contact_group_create_multiple_anonymous;
DO $$
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    PERFORM vibetype.create_contact_groups(ARRAY['Colleagues']);
    RAISE EXCEPTION 'Test failed (contact_group_create_multiple_anonymous): an anonymous invoker created groups';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_create_multiple_anonymous;

SAVEPOINT contact_group_member_create_multiple;
DO $$
DECLARE
  _count INTEGER;
  _group_a UUID;
  _group_a2 UUID;
  _group_b UUID;
  accountA UUID;
  accountB UUID;
  contactA UUID;
  contactA2 UUID;
  contactB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  contactA := vibetype_test.contact_create(accountA, 'c@example.com');
  contactA2 := vibetype_test.contact_create(accountA, 'd@example.com');
  contactB := vibetype_test.contact_create(accountB, 'e@example.com');

  PERFORM vibetype_test.invoker_set(accountB);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountB, 'Other') RETURNING id INTO _group_b;
  PERFORM vibetype_test.invoker_set_previous();

  PERFORM vibetype_test.invoker_set(accountA);
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'One') RETURNING id INTO _group_a;
  INSERT INTO vibetype.contact_group(created_by, name) VALUES (accountA, 'Two') RETURNING id INTO _group_a2;

  SELECT count(*) INTO _count FROM vibetype.create_contact_group_members(ARRAY[_group_a, _group_a2], ARRAY[contactA, contactA2]);
  IF _count <> 2 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): % memberships returned instead of 2', _count;
  END IF;

  -- existing pairs are skipped
  SELECT count(*) INTO _count FROM vibetype.create_contact_group_members(ARRAY[_group_a, _group_a], ARRAY[contactA, contactA2]);
  IF _count <> 1 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): % memberships returned instead of 1 new one', _count;
  END IF;

  SELECT count(*) INTO _count FROM vibetype.contact_group_member;
  IF _count <> 3 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): % memberships exist instead of 3', _count;
  END IF;

  -- another account's group fails the whole call
  BEGIN
    PERFORM vibetype.create_contact_group_members(ARRAY[_group_a2, _group_b], ARRAY[contactA, contactA]);
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): a membership in another account''s group was accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  -- another account's contact fails the whole call
  BEGIN
    PERFORM vibetype.create_contact_group_members(ARRAY[_group_a2, _group_a2], ARRAY[contactA, contactB]);
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): a membership of another account''s contact was accepted';
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
  END;

  -- arrays of different lengths fail the whole call
  BEGIN
    PERFORM vibetype.create_contact_group_members(ARRAY[_group_a2, _group_a2], ARRAY[contactA]);
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): arrays of different lengths were accepted';
  EXCEPTION
    WHEN insufficient_privilege OR not_null_violation THEN
      NULL;
  END;

  SELECT count(*) INTO _count FROM vibetype.contact_group_member;
  IF _count <> 3 THEN
    RAISE EXCEPTION 'Test failed (contact_group_member_create_multiple): % memberships exist after failed calls instead of 3', _count;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$;
ROLLBACK TO SAVEPOINT contact_group_member_create_multiple;

ROLLBACK;
