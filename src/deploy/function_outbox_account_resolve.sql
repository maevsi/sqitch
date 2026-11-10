BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype_private.outbox_account_resolve(account_id uuid) RETURNS TABLE (
  username text,
  email_address text,
  email_address_verification uuid,
  email_address_verification_valid_until timestamp with time zone,
  password_reset_verification uuid,
  password_reset_verification_valid_until timestamp with time zone
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT
    a.username,
    ap.email_address,
    ap.email_address_verification,
    ap.email_address_verification_valid_until,
    ap.password_reset_verification,
    ap.password_reset_verification_valid_until
  FROM vibetype_private.account ap
  JOIN vibetype.account a ON a.id = ap.id
  WHERE ap.id = outbox_account_resolve.account_id;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_account_resolve(UUID) IS 'Returns the account data that emails about an `account` outbox event need, or no row if the account is gone.';

GRANT EXECUTE ON FUNCTION vibetype_private.outbox_account_resolve(UUID) TO :role_service_vibetype_username;

COMMIT;
