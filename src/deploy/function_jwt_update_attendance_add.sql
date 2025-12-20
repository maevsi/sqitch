BEGIN;

CREATE FUNCTION vibetype.jwt_update_attendance_add(
  attendance_id UUID
) RETURNS vibetype.jwt AS $$
DECLARE
  _jwt_id UUID;
  _jwt vibetype.jwt;
BEGIN
  _jwt_id := current_setting('jwt.claims.jti', true)::UUID;

  -- Construct updated JWT with attendance UUID added to attendances array
  _jwt := (
    (SELECT ARRAY(
      SELECT DISTINCT UNNEST(
        COALESCE(
          string_to_array(
            replace(btrim(current_setting('jwt.claims.attendances', true), '[]'), '"', ''),
            ','
          )::UUID[],
          '{}'::UUID[]
        ) || jwt_update_attendance_add.attendance_id
      )
      ORDER BY 1
    )),
    current_setting('jwt.claims.exp', true)::BIGINT,
    (SELECT
      CASE
        WHEN btrim(current_setting('jwt.claims.guests', true), '[]') = '' THEN '{}'::UUID[]
        ELSE string_to_array(
          replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''),
          ','
        )::UUID[]
      END
    ),
    _jwt_id,
    current_setting('jwt.claims.role', true)::TEXT,
    vibetype.invoker_account_id(),
    current_setting('jwt.claims.username', true)::TEXT
  )::vibetype.jwt;

  UPDATE vibetype_private.jwt
  SET token = _jwt
  WHERE id = _jwt_id;

  RETURN _jwt;
END $$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.jwt_update_attendance_add(UUID) IS 'Adds an attendance UUID to the current session JWT.';

GRANT EXECUTE ON FUNCTION vibetype.jwt_update_attendance_add(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
