BEGIN;

CREATE FUNCTION vibetype.outbox_acknowledge(id uuid, is_acknowledged boolean) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  UPDATE vibetype_private.outbox SET is_acknowledged = outbox_acknowledge.is_acknowledged WHERE "outbox".id = outbox_acknowledge.id;

  IF NOT FOUND THEN
    RAISE 'Outbox event with given id not found!' USING ERRCODE = 'no_data_found';
  END IF;
END;
$$;

COMMENT ON FUNCTION vibetype.outbox_acknowledge(UUID, BOOLEAN) IS 'Allows to set the acknowledgement state of an outbox event.\n\nError codes:\n- **P0002** when no outbox event with the given id is found.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_acknowledge(UUID, BOOLEAN) TO vibetype_anonymous;

COMMIT;
