BEGIN;

CREATE FUNCTION vibetype.outbox_is_processed(outbox_id uuid) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM vibetype_private.outbox_processed WHERE "outbox_processed".outbox_id = outbox_is_processed.outbox_id
  );
$$;

COMMENT ON FUNCTION vibetype.outbox_is_processed(UUID) IS 'Returns whether an outbox event has been marked as processed by this consumer.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_is_processed(UUID) TO vibetype_anonymous;

COMMIT;
