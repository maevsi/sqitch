BEGIN;

COMMENT ON FUNCTION vibetype.jwt_create(TEXT, TEXT) IS E'@turnstileProtected\nCreates a JWT token that will securely identify an account and give it certain permissions.';

COMMENT ON FUNCTION vibetype.account_registration(UUID, DATE, UUID, TEXT, TEXT) IS E'@turnstileProtected\nCompletes registration for a confirmed email address verification: creates the account, contact, and legal term acceptance, and fires a welcome email.\n\nError codes:\n- **P0002** when the email address verification is not found or not confirmed.\n- **VTBDA** when the birth date is not at least 18 years old.\n- **VTPLL** when the password length does not reach its minimum.\n- **VTAUV** when an account with the given username already exists.';

COMMIT;
