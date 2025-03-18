BEGIN;

CREATE FUNCTION vibetype.guest_count(event_id UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(1) FROM vibetype.guest WHERE guest.event_id = $1);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.guest_count(UUID) IS 'Returns the guest count for an event.';

GRANT EXECUTE ON FUNCTION vibetype.guest_count(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
