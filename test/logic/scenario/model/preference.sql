\echo test_preference...

BEGIN;

SAVEPOINT preference_select_own;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  _count INTEGER[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.preference_create(accountA, 'category', 'format');

  _count := vibetype_test.preference_count();
  IF _count <> ARRAY[1, 1, 1, 1] THEN
    RAISE EXCEPTION 'Test failed (preference_select_own): expected the owner to see one preference per table, got %', _count;
  END IF;

  PERFORM vibetype_test.invoker_set(accountB);

  _count := vibetype_test.preference_count();
  IF _count <> ARRAY[0, 0, 0, 0] THEN
    RAISE EXCEPTION 'Test failed (preference_select_own): expected another account to see no preferences, got %', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT preference_select_own;


SAVEPOINT preference_insert_other_account;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  _statement TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);

  FOREACH _statement IN ARRAY ARRAY[
    format('INSERT INTO vibetype.preference_event_category (account_id, category_id) SELECT %L, id FROM vibetype.event_category WHERE name = %L', accountB, 'category'),
    format('INSERT INTO vibetype.preference_event_format (account_id, format_id) SELECT %L, id FROM vibetype.event_format WHERE name = %L', accountB, 'format'),
    format('INSERT INTO vibetype.preference_event_location (created_by, location, radius) VALUES (%L, ST_Point(9.476, 51.304, 4326), 50000)', accountB),
    format('INSERT INTO vibetype.preference_event_size (account_id, event_size) VALUES (%L, %L)', accountB, 'small')
  ] LOOP
    BEGIN
      EXECUTE _statement;
      RAISE EXCEPTION 'Test failed (preference_insert_other_account): inserting a preference for another account succeeded: %', _statement;
    EXCEPTION
      WHEN insufficient_privilege THEN
        NULL;
    END;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT preference_insert_other_account;


SAVEPOINT preference_delete_other_account;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  _count INTEGER[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.preference_create(accountA, 'category', 'format');

  PERFORM vibetype_test.invoker_set(accountB);
  DELETE FROM vibetype.preference_event_category;
  DELETE FROM vibetype.preference_event_format;
  DELETE FROM vibetype.preference_event_location;
  DELETE FROM vibetype.preference_event_size;

  PERFORM vibetype_test.invoker_set(accountA);

  _count := vibetype_test.preference_count();
  IF _count <> ARRAY[1, 1, 1, 1] THEN
    RAISE EXCEPTION 'Test failed (preference_delete_other_account): expected another account''s deletes to leave the owner''s preferences intact, got %', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT preference_delete_other_account;


SAVEPOINT preference_delete_own;
DO $$
DECLARE
  accountA UUID;
  _count INTEGER[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.preference_create(accountA, 'category', 'format');

  DELETE FROM vibetype.preference_event_category;
  DELETE FROM vibetype.preference_event_format;
  DELETE FROM vibetype.preference_event_location;
  DELETE FROM vibetype.preference_event_size;

  _count := vibetype_test.preference_count();
  IF _count <> ARRAY[0, 0, 0, 0] THEN
    RAISE EXCEPTION 'Test failed (preference_delete_own): expected the owner to be able to delete their preferences, got %', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT preference_delete_own;


SAVEPOINT preference_unique;
DO $$
DECLARE
  accountA UUID;
  _statement TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.preference_create(accountA, 'category', 'format');

  FOREACH _statement IN ARRAY ARRAY[
    format('INSERT INTO vibetype.preference_event_category (account_id, category_id) SELECT %L, id FROM vibetype.event_category WHERE name = %L', accountA, 'category'),
    format('INSERT INTO vibetype.preference_event_format (account_id, format_id) SELECT %L, id FROM vibetype.event_format WHERE name = %L', accountA, 'format'),
    format('INSERT INTO vibetype.preference_event_location (created_by, location, radius) VALUES (%L, ST_Point(9.476, 51.304, 4326), 50000)', accountA),
    format('INSERT INTO vibetype.preference_event_size (account_id, event_size) VALUES (%L, %L)', accountA, 'small')
  ] LOOP
    BEGIN
      EXECUTE _statement;
      RAISE EXCEPTION 'Test failed (preference_unique): inserting a duplicate preference succeeded: %', _statement;
    EXCEPTION
      WHEN unique_violation THEN
        NULL;
    END;
  END LOOP;
END $$;
ROLLBACK TO SAVEPOINT preference_unique;


SAVEPOINT preference_event_location_radius;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.preference_event_location (created_by, location, radius)
      VALUES (accountA, ST_Point(9.476, 51.304, 4326), 0);
    RAISE EXCEPTION 'Test failed (preference_event_location_radius): a radius of 0 was accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT preference_event_location_radius;


SAVEPOINT preference_account_delete;
DO $$
DECLARE
  accountA UUID;
  _count INTEGER[];
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.event_category_create('category');
  PERFORM vibetype_test.event_format_create('format');

  PERFORM vibetype_test.invoker_set(accountA);
  PERFORM vibetype_test.preference_create(accountA, 'category', 'format');
  PERFORM vibetype.account_delete('password');

  -- the deleted account's id is still the invoker, so any leftover preference would remain visible
  _count := vibetype_test.preference_count();
  IF _count <> ARRAY[0, 0, 0, 0] THEN
    RAISE EXCEPTION 'Test failed (preference_account_delete): expected preferences to be deleted with the account, got %', _count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT preference_account_delete;

ROLLBACK;
