BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_get_functiondef('vibetype_private.trigger_audit_log()'::regprocedure) LIKE '%effective_end%');
END $$;

ROLLBACK;
