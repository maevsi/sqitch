BEGIN;

CREATE FUNCTION vibetype.profile_picture_set(upload_id uuid) RETURNS void
    LANGUAGE sql STRICT
    AS $$
  INSERT INTO vibetype.profile_picture(account_id, upload_id)
  VALUES (
    current_setting('jwt.claims.account_id')::UUID,
    upload_id
  )
  ON CONFLICT (account_id)
  DO UPDATE SET upload_id = EXCLUDED.upload_id;
$$;

COMMENT ON FUNCTION vibetype.profile_picture_set(UUID) IS 'Sets the picture with the given upload id as the invoker''s profile picture.';

GRANT EXECUTE ON FUNCTION vibetype.profile_picture_set(UUID) TO vibetype_account;

COMMIT;
