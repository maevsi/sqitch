BEGIN;

DROP TRIGGER delete ON vibetype_private.outbox;
DROP FUNCTION vibetype_private.trigger_outbox_delete();
DROP FUNCTION vibetype_private.outbox_insert(TEXT, UUID, TEXT, JSONB, INTEGER);
DROP TABLE vibetype_private.outbox;

COMMIT;
