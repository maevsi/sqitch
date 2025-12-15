\echo test_achievement_code/constraints...

BEGIN;

-- Test alias field with exactly 1000 characters (boundary)
SAVEPOINT achievement_code_insert_alias_exact_1000;
DO $$
DECLARE
  alias_1000 TEXT := repeat('a', 1000);
BEGIN
  INSERT INTO vibetype_private.achievement_code (alias, achievement)
  VALUES (alias_1000, 'early_bird');
END $$;
ROLLBACK TO SAVEPOINT achievement_code_insert_alias_exact_1000;

-- Test alias field with 1001 characters (should fail)
SAVEPOINT achievement_code_insert_alias_too_long;
DO $$
DECLARE
  alias_1001 TEXT := repeat('a', 1001);
BEGIN
  BEGIN
    INSERT INTO vibetype_private.achievement_code (alias, achievement)
    VALUES (alias_1001, 'early_bird');
    RAISE EXCEPTION 'Test failed (achievement_code_insert_alias_too_long): alias with 1001 characters accepted';
  EXCEPTION
    WHEN check_violation THEN
      NULL;
    WHEN OTHERS THEN
      RAISE;
  END;
END $$;
ROLLBACK TO SAVEPOINT achievement_code_insert_alias_too_long;

ROLLBACK;
