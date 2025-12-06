BEGIN;

CREATE FUNCTION vibetype.create_guests(event_id uuid, contact_ids uuid[]) RETURNS SETOF vibetype.guest
    LANGUAGE sql STRICT
    AS $$
  INSERT INTO vibetype.guest(event_id, contact_id)
  SELECT event_id, unnest(contact_ids)
  RETURNING *
$$;

COMMENT ON FUNCTION vibetype.create_guests(UUID, UUID[]) IS 'Function for inserting multiple guest records.';

GRANT EXECUTE ON FUNCTION vibetype.create_guests(UUID, UUID[]) TO vibetype_account;

COMMIT;
