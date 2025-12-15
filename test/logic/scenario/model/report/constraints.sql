\echo test_report/constraints...

BEGIN;

-- Test reason field with exactly 2000 characters (boundary)
SAVEPOINT report_insert_reason_exact_2000;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  reason_2000 TEXT := repeat('a', 2000);
  report_id UUID;
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  INSERT INTO vibetype.report(created_by, target_account_id, reason)
  VALUES (accountA, accountB, reason_2000)
  RETURNING id INTO report_id;

  IF report_id IS NULL THEN
    RAISE EXCEPTION 'Test failed (report_insert_reason_exact_2000): report not created';
  END IF;
END $$;
ROLLBACK TO SAVEPOINT report_insert_reason_exact_2000;

-- Test reason field with 2001 characters (should fail)
SAVEPOINT report_insert_reason_too_long;
DO $$
DECLARE
  accountA UUID;
  accountB UUID;
  reason_2001 TEXT := repeat('a', 2001);
BEGIN
  accountA := vibetype_test.account_registration_verified('a', 'a@example.com');
  accountB := vibetype_test.account_registration_verified('b', 'b@example.com');
  PERFORM vibetype_test.invoker_set(accountA);

  BEGIN
    INSERT INTO vibetype.report(created_by, target_account_id, reason)
    VALUES (accountA, accountB, reason_2001);
    RAISE EXCEPTION 'Test failed (report_insert_reason_too_long): reason with 2001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT report_insert_reason_too_long;

ROLLBACK;
