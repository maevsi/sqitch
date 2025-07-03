BEGIN;

-- TODO: refactor into table_preference_location to support multiple locations and radii
CREATE FUNCTION vibetype.account_location_update(
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION
) RETURNS VOID AS $$
BEGIN
  UPDATE vibetype_private.account
    SET location = ST_Point(account_location_update.longitude, account_location_update.latitude, 4326)
    WHERE id = vibetype.invoker_account_id();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account not found'
      USING ERRCODE = 'P0002'; -- no_data_found
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_location_update(DOUBLE PRECISION, DOUBLE PRECISION) IS E'@name update_account_location\nSets the location for the invoker''s account.\n\nError codes:\n- **P0002** when the account is not found.';

GRANT EXECUTE ON FUNCTION vibetype.account_location_update(DOUBLE PRECISION, DOUBLE PRECISION) TO vibetype_account;

COMMIT;
