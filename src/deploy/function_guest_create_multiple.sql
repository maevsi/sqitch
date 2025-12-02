BEGIN;

CREATE FUNCTION vibetype.create_guests(
  event_id UUID,
  contact_ids UUID[]
) RETURNS SETOF vibetype.guest AS $$
  INSERT INTO vibetype.guest(event_id, contact_id)
  SELECT event_id, unnest(contact_ids)
  RETURNING *
$$ LANGUAGE sql STRICT SECURITY INVOKER;

COMMENT ON FUNCTION vibetype.create_guests(UUID, UUID[]) IS 'Function for inserting multiple guest records.';

GRANT EXECUTE ON FUNCTION vibetype.create_guests(UUID, UUID[]) TO vibetype_account;

COMMIT;
