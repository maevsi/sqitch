BEGIN;

CREATE FUNCTION maevsi.invitee_count(event_id UUID)
RETURNS INTEGER AS $$
BEGIN
  RETURN (SELECT COUNT(1) FROM maevsi.invitation WHERE invitation.event_id = $1);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitee_count(UUID) IS 'Returns the invitee count for an event.';

GRANT EXECUTE ON FUNCTION maevsi.invitee_count(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
