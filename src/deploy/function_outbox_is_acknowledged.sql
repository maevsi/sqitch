BEGIN;

CREATE FUNCTION vibetype.outbox_is_acknowledged(id uuid) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(is_acknowledged, FALSE) FROM vibetype_private.outbox WHERE "outbox".id = outbox_is_acknowledged.id;
$$;

COMMENT ON FUNCTION vibetype.outbox_is_acknowledged(UUID) IS 'Returns the acknowledgement state of an outbox event, or null if no outbox event with the given id exists.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_is_acknowledged(UUID) TO vibetype_anonymous;

COMMIT;
