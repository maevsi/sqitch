BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype.outbox_is_processed(outbox_id uuid) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1 FROM vibetype_private.outbox_processed WHERE outbox_processed.outbox_id = outbox_is_processed.outbox_id
  );
$$;

COMMENT ON FUNCTION vibetype.outbox_is_processed(UUID) IS 'Returns whether an outbox event was marked as processed.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_is_processed(UUID) TO :role_service_vibetype_username;

COMMIT;
