BEGIN;

CREATE OR REPLACE FUNCTION vibetype.account_password_change(password_current text, password_new text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _current_account_id UUID;
BEGIN
  IF (char_length(account_password_change.password_new) < 8) THEN
      RAISE 'New password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  _current_account_id := current_setting('jwt.claims.sub')::UUID;

  IF (EXISTS (SELECT 1 FROM vibetype_private.account WHERE account.id = _current_account_id AND account.password_hash = public.crypt(account_password_change.password_current, account.password_hash))) THEN
    UPDATE vibetype_private.account SET password_hash = public.crypt(account_password_change.password_new, public.gen_salt('bf')) WHERE account.id = _current_account_id;
  ELSE
    RAISE 'Account with given password not found!' USING ERRCODE = 'invalid_password';
  END IF;
END;
$$;

CREATE OR REPLACE FUNCTION vibetype.account_password_reset(code uuid, password text) RETURNS void
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
DECLARE
  _account vibetype_private.account;
BEGIN
  IF (char_length(account_password_reset.password) < 8) THEN
    RAISE 'Password too short!' USING ERRCODE = 'invalid_parameter_value';
  END IF;

  SELECT *
    FROM vibetype_private.account
    INTO _account
    WHERE account.password_reset_verification = account_password_reset.code;

  IF (_account IS NULL) THEN
    RAISE 'Unknown reset code!' USING ERRCODE = 'no_data_found';
  END IF;

  IF (_account.password_reset_verification_valid_until < CURRENT_TIMESTAMP) THEN
    RAISE 'Reset code expired!' USING ERRCODE = 'object_not_in_prerequisite_state';
  END IF;

  UPDATE vibetype_private.account
    SET
      password_hash = public.crypt(account_password_reset.password, public.gen_salt('bf')),
      password_reset_verification = NULL
    WHERE account.password_reset_verification = account_password_reset.code;
END;
$$;

COMMIT;
