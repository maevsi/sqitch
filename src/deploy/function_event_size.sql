-- Deploy maevsi:function_event_size to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: table_event
-- requires: role_account
-- requires: role_anonymous

BEGIN;

CREATE FUNCTION maevsi.event_size(p_id UUID)
RETURNS maevsi.event_size AS $$
DECLARE
  _size maevsi.event_size := NULL;
BEGIN
  SELECT
    CASE
      WHEN invitee_count_maximum <= 9 THEN 'small'::maevsi.event_size
      WHEN invitee_count_maximum <= 49 THEN 'medium'::maevsi.event_size
      WHEN invitee_count_maximum <= 999 THEN 'large'::maevsi.event_size
      ELSE 'huge'::maevsi.event_size
    END INTO _size
  FROM maevsi.event
  WHERE id = p_id;

  RETURN _size;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_size(UUID) IS 'For a given event id the function returns the corresponding event size, or null if the event id does not exist.';

GRANT EXECUTE ON FUNCTION maevsi.event_size(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
