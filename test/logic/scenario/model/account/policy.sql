\echo test_account/policy...

BEGIN;

SAVEPOINT account_select;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_test('unblocked account visible to user', accountA, accountB, true);
END $$;
ROLLBACK TO SAVEPOINT account_select;

SAVEPOINT account_select_block_blocker;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_test('blocked account not visible to blocker', accountA, accountB, false);
END $$;
ROLLBACK TO SAVEPOINT account_select_block_blocker;

SAVEPOINT account_select_block_blocked;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.account_block_create(accountA, accountB);

  PERFORM vibetype_test.account_test('blocker not visible to blocked account', accountB, accountA, false);
END $$;
ROLLBACK TO SAVEPOINT account_select_block_blocked;

SAVEPOINT account_update_imprint_valid;
DO $$
DECLARE
  accountA UUID;
  updated_count INTEGER;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  UPDATE vibetype.account
    SET imprint_url = 'https://example.com'
    WHERE id = accountA;

  GET DIAGNOSTICS updated_count = ROW_COUNT;
  IF updated_count != 1 THEN
    RAISE EXCEPTION 'Test failed (account_update_imprint_valid): expected updated_count=1, got %', updated_count;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_valid;

SAVEPOINT account_update_imprint_invalid_protocol;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET imprint_url = 'http://example.com'
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_imprint_invalid_protocol): invalid imprint_url accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_invalid_protocol;

SAVEPOINT account_update_imprint_invalid_space;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET imprint_url = 'https://bad url.example.com'
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_imprint_invalid_space): imprint_url with spaces accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_invalid_space;

SAVEPOINT account_update_imprint_too_long;
DO $$
DECLARE
  accountA UUID;
  long_url TEXT := 'https://enoughchars/' || repeat('a', 2000);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    UPDATE vibetype.account
      SET imprint_url = long_url
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_imprint_too_long): long imprint_url accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_too_long;

SAVEPOINT account_update_imprint_anonymous;
DO $$
DECLARE
  accountA UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set_anonymous();

  BEGIN
    UPDATE vibetype.account
      SET imprint_url = 'https://example.com'
      WHERE id = accountA;
    RAISE EXCEPTION 'Test failed (account_update_imprint_anonymous): anonymous invoker was able to update account %', accountA;
  EXCEPTION
    WHEN insufficient_privilege THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT account_update_imprint_anonymous;

ROLLBACK;
