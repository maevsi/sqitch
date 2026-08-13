BEGIN;

COMMENT ON FUNCTION vibetype.jwt_create(TEXT, TEXT) IS 'Creates a JWT token that will securely identify an account and give it certain permissions.';

COMMENT ON FUNCTION vibetype.account_registration(DATE, TEXT, TEXT, UUID, TEXT, TEXT) IS E'Creates a contact and registers an account referencing it.\n\nError codes:\n- **VTBDA** when the birth date is not at least 18 years old.\n- **VTPLL** when the password length does not reach its minimum.\n- **VTAUV** when an account with the given username already exists.';

COMMIT;
