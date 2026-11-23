BEGIN;

DO $$
BEGIN
  ASSERT (SELECT prosrc LIKE '%vibetype_private.outbox_insert(%' FROM pg_proc WHERE oid = 'vibetype.account_delete(TEXT)'::regprocedure);
END $$;

ROLLBACK;
