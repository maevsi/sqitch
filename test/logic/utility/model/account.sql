CREATE OR REPLACE FUNCTION vibetype_test.account_delete (
  _username TEXT
) RETURNS VOID AS $$
DECLARE
  _id UUID;
BEGIN
  SELECT id INTO _id FROM vibetype.account WHERE username = _username;

  IF _id IS NOT NULL THEN

    PERFORM vibetype_test.invoker_set(_id);

    DELETE FROM vibetype.event WHERE created_by = _id;

    PERFORM vibetype.account_delete('password');

    PERFORM vibetype_test.invoker_set_empty();
  END IF;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.account_delete(TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_select_address_coordinates(
  _account_id UUID
)
RETURNS DOUBLE PRECISION[] AS $$
DECLARE
  _latitude DOUBLE PRECISION;
  _longitude DOUBLE PRECISION;
BEGIN
  SELECT
    ST_Y(location::geometry),
    ST_X(location::geometry)
  INTO
    _latitude,
    _longitude
  FROM
    vibetype_private.account
  WHERE
    id = _account_id;

  RETURN ARRAY[_latitude, _longitude];
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.account_select_address_coordinates(UUID) IS 'Returns an array with latitude and longitude of the account''s current location data';

GRANT EXECUTE ON FUNCTION vibetype_test.account_select_address_coordinates(UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_select_by_email_address(_email_address text)
RETURNS UUID AS $$
DECLARE
  _account_id UUID;
BEGIN
  SELECT id
  INTO _account_id
  FROM vibetype_private.account
  WHERE email_address = _email_address;

  RETURN _account_id;
END;
$$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_select_by_email_address(TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_select_by_event_distance(
  _event_id UUID,
  _distance_max DOUBLE PRECISION
)
RETURNS TABLE (
  account_id UUID,
  distance DOUBLE PRECISION
) AS $$
BEGIN
  RETURN QUERY
    WITH event AS (
      SELECT address_id
      FROM vibetype.event
      WHERE id = _event_id
    ),
    event_address AS (
      SELECT location
      FROM vibetype.address
      WHERE id = (SELECT address_id FROM event)
    )
    SELECT
      a.id AS account_id,
      ST_Distance(e.location, a.location) AS distance
    FROM
      event_address e,
      vibetype_private.account a
    WHERE
      ST_DWithin(e.location, a.location, _distance_max * 1000);
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.account_select_by_event_distance(UUID, DOUBLE PRECISION) IS 'Returns account locations within a given radius around the location of an event.';

GRANT EXECUTE ON FUNCTION vibetype_test.account_select_by_event_distance(UUID, DOUBLE PRECISION) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_update_address_coordinates(
  _account_id UUID,
  _latitude DOUBLE PRECISION,
  _longitude DOUBLE PRECISION
)
RETURNS VOID AS $$
BEGIN
  UPDATE vibetype_private.account
  SET
    location = ST_Point(_longitude, _latitude, 4326)
  WHERE
    id = _account_id;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_test.account_update_address_coordinates(UUID, DOUBLE PRECISION, DOUBLE PRECISION) IS 'Updates an account''s location based on latitude and longitude (GPS coordinates).';

GRANT EXECUTE ON FUNCTION vibetype_test.account_update_address_coordinates(UUID, DOUBLE PRECISION, DOUBLE PRECISION) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.account_test(
  _test_case TEXT,
  _invoker_account_id UUID,
  _account_id UUID,
  _assert_is_visible BOOLEAN
) RETURNS VOID AS $$
DECLARE
  _result BOOLEAN;
BEGIN
  PERFORM vibetype_test.invoker_set(_invoker_account_id);

  SELECT true INTO _result
  FROM vibetype.account
  WHERE id = _account_id;

  IF _result IS NULL AND _assert_is_visible THEN
    RAISE EXCEPTION '%: account % should be visible but is not.', _test_case, _account_id;
  END IF;

  IF _result AND NOT _assert_is_visible THEN
    RAISE EXCEPTION '%: account % is visible but should not.', _test_case, _account_id;
  END IF;

  PERFORM vibetype_test.invoker_set_empty();
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY INVOKER;

GRANT EXECUTE ON FUNCTION vibetype_test.account_test(TEXT, UUID, UUID, BOOLEAN) TO vibetype_account;
