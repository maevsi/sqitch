BEGIN;

CREATE FUNCTION vibetype.account_birth_date_update(
  birth_date DATE
) RETURNS VOID AS $$
DECLARE
  birth_date_existing DATE;
BEGIN
  SELECT account.birth_date
    INTO birth_date_existing
    FROM vibetype_private.account
    WHERE id = vibetype.invoker_account_id();

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Account not found'
      USING ERRCODE = 'no_data_found'; -- P0002
  END IF;

  IF birth_date_existing IS NOT NULL THEN
    RAISE EXCEPTION 'Birth date is already set'
      USING ERRCODE = 'check_violation'; -- 23514
  END IF;

  IF birth_date > CURRENT_DATE - INTERVAL '18 years' THEN
    RAISE EXCEPTION 'You must be at least 18 years old'
      USING ERRCODE = 'invalid_parameter_value'; -- 22023
  END IF;

  UPDATE vibetype_private.account
    SET birth_date = account_birth_date_update.birth_date
    WHERE id = vibetype.invoker_account_id();
END;
$$ LANGUAGE PLPGSQL STRICT VOLATILE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.account_birth_date_update(DATE) IS E'@name update_account_birth_date\nSets the birth date for the invoker''s account.\n\nError codes:\n- **P0002** when no record was updated\n- **23514** when the birth date is already set\n- **22023** when the birth date is not at least 18 years ago';

GRANT EXECUTE ON FUNCTION vibetype.account_birth_date_update(DATE) TO vibetype_account;

COMMIT;
