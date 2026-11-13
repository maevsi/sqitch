BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.pg_get_functiondef('vibetype.jwt_create(TEXT, TEXT)'::regprocedure) LIKE '%_jwt_expired_delete%');
END $$;

ROLLBACK;
