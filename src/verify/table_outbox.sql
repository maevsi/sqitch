BEGIN;

SELECT id,
       aggregate_type,
       aggregate_id,
       type,
       payload,
       created_at
FROM vibetype_private.outbox WHERE FALSE;

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.outbox_insert(TEXT, UUID, TEXT, JSONB, INTEGER)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.outbox_insert(TEXT, UUID, TEXT, JSONB, INTEGER)', 'EXECUTE'));
  ASSERT (SELECT 1 FROM pg_trigger WHERE tgrelid = 'vibetype_private.outbox'::regclass AND tgname = 'delete' AND tgenabled = 'O') = 1;
END $$;

ROLLBACK;
