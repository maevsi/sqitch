BEGIN;

CREATE FUNCTION maevsi.event_is_existing(
  author_account_id UUID,
  slug TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  IF (EXISTS (SELECT 1 FROM maevsi.event WHERE "event".author_account_id = $1 AND "event".slug = $2)) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_is_existing(UUID, TEXT) IS 'Shows if an event exists.';

GRANT EXECUTE ON FUNCTION maevsi.event_is_existing(UUID, TEXT) TO maevsi_account, maevsi_anonymous;

COMMIT;
