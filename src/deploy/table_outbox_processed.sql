BEGIN;

-- Not foreign-keyed to vibetype_private.outbox, whose rows are deleted right after their insertion.
-- Grows by one row per processed event. Markers older than the topic retention can be deleted safely;
-- upgrade path: schedule `DELETE ... WHERE processed_at < now() - interval '30 days'`.
CREATE TABLE vibetype_private.outbox_processed (
  outbox_id     UUID PRIMARY KEY,

  processed_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype_private.outbox_processed IS 'An idempotency marker recording that a consumer processed an outbox event.';
COMMENT ON COLUMN vibetype_private.outbox_processed.outbox_id IS 'The processed outbox event''s id.';
COMMENT ON COLUMN vibetype_private.outbox_processed.processed_at IS 'The timestamp the outbox event was marked as processed.';

COMMIT;
