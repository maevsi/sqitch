BEGIN;

CREATE FUNCTION maevsi.event_is_existing(
  created_by UUID,
  slug TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  IF (EXISTS (SELECT 1 FROM maevsi.event WHERE "event".created_by = event_is_existing.created_by AND "event".slug = event_is_existing.slug)) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_is_existing(UUID, TEXT) IS 'Shows if an event exists.';

GRANT EXECUTE ON FUNCTION maevsi.event_is_existing(UUID, TEXT) TO maevsi_account, maevsi_anonymous;

COMMIT;
