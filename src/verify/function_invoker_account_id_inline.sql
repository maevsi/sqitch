BEGIN;

DO $$
BEGIN
  IF (SELECT proisstrict FROM pg_proc WHERE oid = 'vibetype.invoker_account_id()'::regprocedure) THEN
    RAISE EXCEPTION 'vibetype.invoker_account_id() is still strict, so it cannot be inlined.';
  END IF;
END $$;

ROLLBACK;
