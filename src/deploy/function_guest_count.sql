BEGIN;

CREATE FUNCTION maevsi.guest_count(event_id UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(1) FROM maevsi.guest WHERE guest.event_id = guest_count.event_id);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.guest_count(UUID) IS 'Returns the guest count for an event.';

GRANT EXECUTE ON FUNCTION maevsi.guest_count(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
