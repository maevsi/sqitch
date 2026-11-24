\echo test_account_display_name...

BEGIN;

SAVEPOINT account_display_name_update_own;
DO $$
DECLARE
  accountA UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET display_name = 'Jonas Thelemann'
    WHERE id = accountA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_display_name_update_own): expected updated_count=1, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_update_own;

SAVEPOINT account_display_name_update_exact_100;
DO $$
DECLARE
  accountA UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET display_name = repeat('a', 100)
    WHERE id = accountA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_display_name_update_exact_100): expected updated_count=1, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_update_exact_100;

SAVEPOINT account_display_name_update_empty;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET display_name = ''
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_display_name_update_empty): empty display name accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_update_empty;

SAVEPOINT account_display_name_update_too_long;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET display_name = repeat('a', 101)
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_display_name_update_too_long): display name with 101 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_update_too_long;

SAVEPOINT account_display_name_update_other;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET display_name = 'Not B'
    WHERE id = accountB;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 0 THEN
    RAISE EXCEPTION 'Test failed (account_display_name_update_other): expected updated_count=0, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_update_other;

SAVEPOINT account_display_name_select_anonymous;
DO $$
DECLARE
  accountA UUID;
  _display_name TEXT;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET display_name = 'Musikverein Kassel'
    WHERE id = accountA;

  PERFORM vibetype_test.invoker_set_previous();
  PERFORM vibetype_test.invoker_set_anonymous();

  SELECT display_name INTO _display_name FROM vibetype.account WHERE id = accountA;

  IF _display_name IS DISTINCT FROM 'Musikverein Kassel' THEN
    RAISE EXCEPTION 'Test failed (account_display_name_select_anonymous): expected display name, got %', _display_name;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_display_name_select_anonymous;

ROLLBACK;
