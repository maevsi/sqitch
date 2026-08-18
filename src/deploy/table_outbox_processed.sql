BEGIN;

-- No foreign key to vibetype_private.outbox.id: this marker must outlive the outbox row's short
-- retention window (see table_outbox.sql), so a late duplicate delivery can still be recognized
-- as already processed after its source row has been purged.
CREATE TABLE vibetype_private.outbox_processed (
  outbox_id     UUID PRIMARY KEY,

  processed_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype_private.outbox_processed IS 'A per-consumer idempotency marker recording that an outbox event has been processed. Deliberately not foreign-keyed to vibetype_private.outbox, since it must outlive that table''s retention purge.';
COMMENT ON COLUMN vibetype_private.outbox_processed.outbox_id IS 'The processed outbox event''s id.';
COMMENT ON COLUMN vibetype_private.outbox_processed.processed_at IS 'The timestamp the outbox event was marked as processed.';

COMMIT;
