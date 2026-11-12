BEGIN;

DO $$
BEGIN
  ASSERT (SELECT prosrc LIKE '%vibetype_private.outbox_insert(%' FROM pg_proc WHERE oid = 'vibetype.account_password_reset_request(TEXT, TEXT, TEXT)'::regprocedure);
END $$;

ROLLBACK;
