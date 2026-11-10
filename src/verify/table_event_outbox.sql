BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.trigger_event_outbox()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.trigger_event_outbox()', 'EXECUTE'));
END $$;

ROLLBACK;
