BEGIN;

CREATE FUNCTION vibetype.create_guests(
  event_id UUID,
  contact_ids UUID[]
) RETURNS SETOF vibetype.guest AS $$
DECLARE
  _contact_id UUID;
  _id UUID;
  _id_array UUID[] := ARRAY[]::UUID[];
BEGIN
  FOREACH _contact_id IN ARRAY create_guests.contact_ids LOOP
    INSERT INTO vibetype.guest(event_id, contact_id)
      VALUES (create_guests.event_id, _contact_id)
      RETURNING id INTO _id;

    _id_array := array_append(_id_array, _id);
  END LOOP;

  RETURN QUERY
    SELECT *
    FROM vibetype.guest
    WHERE id = ANY (_id_array);
END $$ LANGUAGE PLPGSQL STRICT SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.create_guests(UUID, UUID[]) IS 'Function for inserting multiple guest records.';

GRANT EXECUTE ON FUNCTION vibetype.create_guests(UUID, UUID[]) TO vibetype_account;

COMMIT;
