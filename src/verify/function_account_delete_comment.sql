BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.obj_description('vibetype.account_delete(TEXT)'::regprocedure, 'pg_proc') LIKE '%several seconds%');
  ASSERT (SELECT pg_catalog.obj_description('vibetype.account_delete(TEXT)'::regprocedure, 'pg_proc') NOT LIKE '%23503%');
END $$;

ROLLBACK;
