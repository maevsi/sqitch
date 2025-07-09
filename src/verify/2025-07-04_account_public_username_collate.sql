BEGIN;

DO $$
DECLARE
  actual_collation TEXT;
BEGIN
  SELECT c.collname INTO actual_collation
  FROM pg_attribute a
  JOIN pg_class t ON a.attrelid = t.oid
  JOIN pg_namespace n ON t.relnamespace = n.oid
  LEFT JOIN pg_collation c ON a.attcollation = c.oid
  WHERE t.relname = 'account'
    AND a.attname = 'username'
    AND a.attnum > 0
    AND NOT a.attisdropped;

  IF actual_collation IS DISTINCT FROM 'unicode' THEN
    RAISE EXCEPTION 'Collation mismatch: expected unicode, found %', actual_collation;
  END IF;
END $$;

ROLLBACK;
