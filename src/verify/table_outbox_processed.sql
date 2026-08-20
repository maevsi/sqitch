BEGIN;

SELECT outbox_id, processed_at
FROM vibetype_private.outbox_processed WHERE FALSE;

ROLLBACK;
