-- Deploy maevsi:function_event_delete to pg
-- requires: privilege_execute_revoke
-- requires: schema_public
-- requires: role_account
-- requires: table_account_private
-- requires: table_event
-- requires: extension_pgcrypto

BEGIN;

CREATE FUNCTION maevsi.event_delete(
  id UUID,
  "password" TEXT
) RETURNS maevsi.event AS $$
DECLARE
  _current_account_id UUID;
  _event_deleted maevsi.event;
BEGIN
  _current_account_id := current_setting('jwt.claims.account_id')::UUID;

  IF (EXISTS (SELECT 1 FROM maevsi_private.account WHERE account.id = _current_account_id AND account.password_hash = maevsi.crypt($2, account.password_hash))) THEN
    DELETE
      FROM maevsi.event
      WHERE
            "event".id = $1
        AND "event".author_account_id = _current_account_id
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

COMMENT ON FUNCTION maevsi.event_delete(UUID, TEXT) IS 'Allows to delete an event.';

GRANT EXECUTE ON FUNCTION maevsi.event_delete(UUID, TEXT) TO maevsi_account;

COMMIT;
