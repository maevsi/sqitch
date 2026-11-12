BEGIN;

CREATE OR REPLACE FUNCTION vibetype.account_password_reset_request(email_address text, language text, time_zone text DEFAULT 'UTC') RETURNS void
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH updated AS (
    UPDATE vibetype_private.account
    SET password_reset_verification = gen_random_uuid()
    WHERE email_address = account_password_reset_request.email_address
    RETURNING id
  )
  SELECT vibetype_private.outbox_insert(
    'account',
    updated.id,
    'account.password_reset_requested',
    jsonb_build_object('account_id', updated.id, 'language', account_password_reset_request.language, 'time_zone', account_password_reset_request.time_zone)
  )
  FROM updated;
$$;

COMMIT;
