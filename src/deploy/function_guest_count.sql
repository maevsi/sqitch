BEGIN;

CREATE FUNCTION vibetype.guest_count(event_id UUID)
RETURNS INTEGER AS $$
  SELECT COUNT(1) FROM vibetype.guest WHERE guest.event_id = guest_count.event_id;
$$ LANGUAGE sql STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.guest_count(UUID) IS 'Returns the guest count for an event.';

GRANT EXECUTE ON FUNCTION vibetype.guest_count(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
