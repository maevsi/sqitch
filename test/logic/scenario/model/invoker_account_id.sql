\echo test_invoker_account_id...

BEGIN;

SAVEPOINT invoker_account_id_set;
DO $$
DECLARE
  accountA UUID;
  invokerId UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');

  PERFORM vibetype_test.invoker_set(accountA);

  invokerId := vibetype.invoker_account_id();

  -- Should return the set account ID
  IF invokerId != accountA THEN
    RAISE EXCEPTION 'Test failed: expected invoker_account_id to be %, got %', accountA, invokerId;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT invoker_account_id_set;

SAVEPOINT invoker_account_id_empty;
DO $$
DECLARE
  invokerId UUID;
BEGIN
  PERFORM vibetype_test.invoker_set_empty();

  invokerId := vibetype.invoker_account_id();

  -- Should return NULL when not set
  IF invokerId IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: expected invoker_account_id to be NULL, got %', invokerId;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT invoker_account_id_empty;

SAVEPOINT invoker_account_id_anonymous;
DO $$
DECLARE
  invokerId UUID;
BEGIN
  PERFORM vibetype_test.invoker_set_anonymous();

  invokerId := vibetype.invoker_account_id();

  -- Should return NULL for anonymous user
  IF invokerId IS NOT NULL THEN
    RAISE EXCEPTION 'Test failed: expected invoker_account_id to be NULL for anonymous, got %', invokerId;
  END IF;
END $$;
ROLLBACK TO SAVEPOINT invoker_account_id_anonymous;

SAVEPOINT invoker_account_id_switch;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  invokerId UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');

  PERFORM vibetype_test.invoker_set(accountA);
  invokerId := vibetype.invoker_account_id();

  -- Should return account A
  IF invokerId != accountA THEN
    RAISE EXCEPTION 'Test failed: expected invoker_account_id to be account A';
  END IF;

  PERFORM vibetype_test.invoker_set(accountB);
  invokerId := vibetype.invoker_account_id();

  -- Should now return account B
  IF invokerId != accountB THEN
    RAISE EXCEPTION 'Test failed: expected invoker_account_id to be account B after switch';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT invoker_account_id_switch;

ROLLBACK;
