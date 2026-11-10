BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.trigger_upload_outbox()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.trigger_upload_outbox()', 'EXECUTE'));
END $$;

ROLLBACK;
