BEGIN;

CREATE FUNCTION maevsi.guest_create_multiple(
  event_id UUID,
  contact_ids UUID[]
) RETURNS SETOF maevsi.guest AS $$
DECLARE
  _contact_id UUID;
  _id UUID;
  _id_array UUID[] := ARRAY[]::UUID[];
BEGIN

  FOREACH _contact_id IN ARRAY guest_create_multiple.contact_ids LOOP

    INSERT INTO maevsi.guest(event_id, contact_id)
    VALUES (guest_create_multiple.event_id, _contact_id)
    RETURNING id INTO _id;

    _id_array := array_append(_id_array, _id);

  END LOOP;

  RETURN QUERY
    SELECT *
    FROM maevsi.guest
    WHERE id = ANY (_id_array);

END $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.guest_create_multiple(UUID, UUID[]) IS 'Function for inserting multiple guest records.';

GRANT EXECUTE ON FUNCTION maevsi.guest_create_multiple(UUID, UUID[]) TO maevsi_account;

COMMIT;
