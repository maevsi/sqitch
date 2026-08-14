BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype.outbox_payload_account(account_id uuid) RETURNS TABLE (
  email_address text,
  email_address_verification uuid,
  email_address_verification_valid_until timestamp with time zone,
  password_reset_verification uuid,
  password_reset_verification_valid_until timestamp with time zone,
  username text
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT
    ap.email_address,
    ap.email_address_verification,
    ap.email_address_verification_valid_until,
    ap.password_reset_verification,
    ap.password_reset_verification_valid_until,
    a.username
  FROM vibetype_private.account ap
  JOIN vibetype.account a ON a.id = ap.id
  WHERE ap.id = outbox_payload_account.account_id;
$$;

COMMENT ON FUNCTION vibetype.outbox_payload_account(UUID) IS 'Fetches the account data needed to compose account-related outbox emails (registration, password reset), keyed by account id. Kept out of the outbox payload itself so this personal data never reaches the CDC log.';

GRANT EXECUTE ON FUNCTION vibetype.outbox_payload_account(UUID) TO :role_service_vibetype_username;

COMMIT;
