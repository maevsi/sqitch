BEGIN;

DO $$
BEGIN
  ASSERT (SELECT prosrc LIKE '%vibetype_private.outbox_insert(%' FROM pg_proc WHERE oid = 'vibetype.invite(UUID, TEXT)'::regprocedure);
END $$;

ROLLBACK;
