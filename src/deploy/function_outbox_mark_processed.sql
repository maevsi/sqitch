BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype.outbox_mark_processed(outbox_id uuid) RETURNS void
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  DELETE FROM vibetype_private.outbox_processed WHERE processed_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

  INSERT INTO vibetype_private.outbox_processed (outbox_id) VALUES (outbox_mark_processed.outbox_id)
  ON CONFLICT (outbox_id) DO NOTHING;
$$;

COMMENT ON FUNCTION vibetype.outbox_mark_processed(UUID) IS 'Marks an outbox event as processed. Marking an already processed event again has no effect. Markers older than 30 days are deleted along the way.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_mark_processed(UUID) TO :role_service_vibetype_username;

COMMIT;
