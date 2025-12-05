CREATE OR REPLACE FUNCTION vibetype_test.invoker_set(
  _invoker_id UUID
)
RETURNS VOID AS $$
BEGIN
  -- Store the current role and account_id before setting a new one
  PERFORM set_config('vibetype_test.previous_role', session_user, true);
  PERFORM set_config('vibetype_test.previous_account_id', COALESCE(current_setting('jwt.claims.account_id', true), ''), true);
  SET LOCAL ROLE = 'vibetype_account';
  PERFORM set_config('jwt.claims.account_id', _invoker_id::TEXT, true);
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set(UUID) TO vibetype_account, vibetype_anonymous;


CREATE OR REPLACE FUNCTION vibetype_test.invoker_set_anonymous()
RETURNS VOID AS $$
BEGIN
  -- Store the current role and account_id before setting a new one
  PERFORM set_config('vibetype_test.previous_role', session_user, true);
  PERFORM set_config('vibetype_test.previous_account_id', COALESCE(current_setting('jwt.claims.account_id', true), ''), true);
  SET LOCAL ROLE = 'vibetype_anonymous';
  PERFORM set_config('jwt.claims.account_id', '', true);
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set_anonymous() TO vibetype_account, vibetype_anonymous;


CREATE OR REPLACE FUNCTION vibetype_test.invoker_set_previous()
RETURNS VOID AS $$
BEGIN
  -- Restore the previous role and account_id
  DECLARE
    _previous_role TEXT := current_setting('vibetype_test.previous_role', true);
    _previous_account_id TEXT := current_setting('vibetype_test.previous_account_id', true);
  BEGIN
    IF _previous_role IS NOT NULL THEN
      EXECUTE 'SET LOCAL ROLE = ' || quote_ident(_previous_role);
    ELSE
      SET LOCAL ROLE NONE;
    END IF;
    PERFORM set_config('jwt.claims.account_id', COALESCE(_previous_account_id, ''), true);
  END;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set_previous() TO vibetype_account, vibetype_anonymous;


CREATE OR REPLACE FUNCTION vibetype_test.invoker_set_empty()
RETURNS VOID AS $$
BEGIN
  SET LOCAL ROLE NONE;
  PERFORM set_config('jwt.claims.account_id', '', true);
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.invoker_set_empty() TO vibetype_account, vibetype_anonymous;
