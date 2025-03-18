BEGIN;

CREATE FUNCTION vibetype.event_is_existing(
  created_by UUID,
  slug TEXT
) RETURNS BOOLEAN AS $$
BEGIN
  IF (EXISTS (SELECT 1 FROM vibetype.event WHERE "event".created_by = $1 AND "event".slug = $2)) THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.event_is_existing(UUID, TEXT) IS 'Shows if an event exists.';

GRANT EXECUTE ON FUNCTION vibetype.event_is_existing(UUID, TEXT) TO vibetype_account, vibetype_anonymous;

COMMIT;
