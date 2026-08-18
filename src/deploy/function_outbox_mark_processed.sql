BEGIN;

CREATE FUNCTION vibetype.outbox_mark_processed(outbox_id uuid) RETURNS void
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  INSERT INTO vibetype_private.outbox_processed (outbox_id) VALUES (outbox_mark_processed.outbox_id)
  ON CONFLICT (outbox_id) DO NOTHING;
$$;

COMMENT ON FUNCTION vibetype.outbox_mark_processed(UUID) IS 'Marks an outbox event as processed by this consumer. Idempotent: a repeat call for an already-processed id is a no-op.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_mark_processed(UUID) TO vibetype_anonymous;

COMMIT;
