BEGIN;

CREATE FUNCTION vibetype.event_delete(
  id UUID,
  "password" TEXT
) RETURNS vibetype.event AS $$
DECLARE
  _current_account_id UUID;
  _event_deleted vibetype.event;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = crypt($2, account.password_hash))) THEN
    DELETE
      FROM vibetype.event
      WHERE
            "event".id = $1
        AND "event".created_by = _current_account_id
      RETURNING * INTO _event_deleted;

    IF (_event_deleted IS NULL) THEN
      RAISE 'Event not found!' USING ERRCODE = 'no_data_found';
    ELSE
      RETURN _event_deleted;
    END IF;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.event_delete(UUID, TEXT) IS 'Allows to delete an event.';

GRANT EXECUTE ON FUNCTION vibetype.event_delete(UUID, TEXT) TO vibetype_account;

COMMIT;
