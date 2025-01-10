BEGIN;

DO $$
DECLARE
  _account_id UUID;
  _code UUID;
  _jwt maevsi.jwt;
BEGIN

  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_account', 'maevsi.authenticate(TEXT, TEXT)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('maevsi_anonymous', 'maevsi.authenticate(TEXT, TEXT)', 'EXECUTE'));

  -- register test account and shortcut email verification

  _account_id := maevsi.account_registration('ameier', 'anton.meier@abc.de', 'abcd1234', 'de');

  PERFORM maevsi.account_email_address_verification(
    (SELECT email_address_verification FROM maevsi_private.account WHERE id = _account_id)
  );

  --===================================
  -- run tests

  RAISE NOTICE 'test 1: login with correct username/password';

  _jwt := maevsi.authenticate('ameier', 'abcd1234');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Authentication should have been returned a JWT.';
  END IF;

  IF _jwt.account_username <> 'ameier' THEN
    RAISE EXCEPTION 'JWT contains a wrong user name.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'test 2: login with correct email address/password';

  _jwt := maevsi.authenticate('anton.meier@abc.de', 'abcd1234');

  IF _jwt IS NULL THEN
    RAISE EXCEPTION 'Authentication should have been returned a JWT.';
  END IF;

  IF _jwt.account_username <> 'ameier' THEN
    RAISE EXCEPTION 'JWT contains a wrong user name.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'test 3: login with correct username and incorrect password';

  BEGIN
    _jwt := maevsi.authenticate('ameier', 'xyz');
  EXCEPTION
    WHEN no_data_found THEN
      -- expected exception, do nothing
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Authentication should not have returned a JWT.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'test 4: login with correct email address and incorrect password';

  BEGIN
    _jwt := maevsi.authenticate('anton.meier@abc.de', 'xyz');
  EXCEPTION
    WHEN no_data_found THEN
      -- expected exception, do nothing
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Authentication should not have returned a JWT.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'test 5: login with incorrect username';

  BEGIN
    _jwt := maevsi.authenticate('axmeier', 'abcd1234');
  EXCEPTION
    WHEN no_data_found THEN
      -- expected exception, do nothing
  END;

  -------------------------------------

  RAISE NOTICE 'test 6: login with incorrect email address';

  BEGIN
    _jwt := maevsi.authenticate('antonx.meier@abc.de', 'abcd1234');
  EXCEPTION
    WHEN no_data_found THEN
      -- expected exception, do nothing
  END;

  IF _jwt IS NOT NULL THEN
    RAISE EXCEPTION 'Authentication should not have returned a JWT.';
  END IF;

  -------------------------------------

  RAISE NOTICE 'all tests passed successfully.';
END $$;

ROLLBACK;
