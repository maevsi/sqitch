\echo test_event/constraints...

BEGIN;

-- Test description field with exactly 10000 characters (boundary)
SAVEPOINT event_insert_description_exact_10000;
DO $$
DECLARE
  accountA UUID;
  description_10000 TEXT := repeat('a', 10000);
  event_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility, description)
  VALUES (accountA, 'Test Event', 'test-event', NOW(), 'public', description_10000)
  RETURNING id INTO event_id;

  IF event_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (event_insert_description_exact_10000): event not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_insert_description_exact_10000;

-- Test description field with 10001 characters (should fail)
SAVEPOINT event_insert_description_too_long;
DO $$
DECLARE
  accountA UUID;
  description_10001 TEXT := repeat('a', 10001);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.event(created_by, name, slug, start, visibility, description)
    VALUES (accountA, 'Test Event', 'test-event', NOW(), 'public', description_10001);
    RAISE EXCEPTION 'Test failed (event_insert_description_too_long): description with 10001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_insert_description_too_long;

-- Test name field with exactly 100 characters (boundary)
SAVEPOINT event_insert_name_exact_100;
DO $$
DECLARE
  accountA UUID;
  name_100 TEXT := repeat('a', 100);
  event_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
  VALUES (accountA, name_100, 'test-event', NOW(), 'public')
  RETURNING id INTO event_id;

  IF event_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (event_insert_name_exact_100): event not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_insert_name_exact_100;

-- Test name field with 101 characters (should fail)
SAVEPOINT event_insert_name_too_long;
DO $$
DECLARE
  accountA UUID;
  name_101 TEXT := repeat('a', 101);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
    VALUES (accountA, name_101, 'test-event', NOW(), 'public');
    RAISE EXCEPTION 'Test failed (event_insert_name_too_long): name with 101 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_insert_name_too_long;

-- Test slug field with exactly 100 characters (boundary)
SAVEPOINT event_insert_slug_exact_100;
DO $$
DECLARE
  accountA UUID;
  slug_100 TEXT := repeat('a', 100);
  event_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
  VALUES (accountA, 'Test Event', slug_100, NOW(), 'public')
  RETURNING id INTO event_id;

  IF event_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (event_insert_slug_exact_100): event not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_insert_slug_exact_100;

-- Test slug field with 101 characters (should fail)
SAVEPOINT event_insert_slug_too_long;
DO $$
DECLARE
  accountA UUID;
  slug_101 TEXT := repeat('a', 101);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.event(created_by, name, slug, start, visibility)
    VALUES (accountA, 'Test Event', slug_101, NOW(), 'public');
    RAISE EXCEPTION 'Test failed (event_insert_slug_too_long): slug with 101 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_insert_slug_too_long;

-- Test url field with exactly 2000 characters (boundary)
SAVEPOINT event_insert_url_exact_2000;
DO $$
DECLARE
  accountA UUID;
  url_2000 TEXT := 'https://example.com/' || repeat('a', 1980);
  event_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.event(created_by, name, slug, start, visibility, url)
  VALUES (accountA, 'Test Event', 'test-event', NOW(), 'public', url_2000)
  RETURNING id INTO event_id;

  IF event_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (event_insert_url_exact_2000): event not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT event_insert_url_exact_2000;

-- Test url field with 2001 characters (should fail)
SAVEPOINT event_insert_url_too_long;
DO $$
DECLARE
  accountA UUID;
  url_2001 TEXT := 'https://example.com/' || repeat('a', 1981);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.event(created_by, name, slug, start, visibility, url)
    VALUES (accountA, 'Test Event', 'test-event', NOW(), 'public', url_2001);
    RAISE EXCEPTION 'Test failed (event_insert_url_too_long): url with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT event_insert_url_too_long;

ROLLBACK;
