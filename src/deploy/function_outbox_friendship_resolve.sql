BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype_private.outbox_friendship_resolve(friendship_id uuid) RETURNS TABLE (
  recipient_account_id uuid,
  recipient_email_address text,
  recipient_language text,
  recipient_username text,
  sender_username text,
  status text
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT
    recipient.id,
    recipient_private.email_address,
    recipient_contact.language::text,
    recipient.username,
    sender.username,
    f.status::text
  FROM vibetype.friendship f
  -- A request is sent by its creator, an acceptance by the other account.
  CROSS JOIN LATERAL (
    SELECT CASE WHEN f.created_by = f.account_a_id THEN f.account_b_id ELSE f.account_a_id END AS id
  ) requested
  JOIN vibetype.account sender ON sender.id = CASE f.status WHEN 'requested' THEN f.created_by ELSE requested.id END
  JOIN vibetype.account recipient ON recipient.id = CASE f.status WHEN 'requested' THEN requested.id ELSE f.created_by END
  JOIN vibetype_private.account recipient_private ON recipient_private.id = recipient.id
  LEFT JOIN vibetype.contact recipient_contact ON recipient_contact.account_id = recipient.id AND recipient_contact.created_by = recipient.id
  WHERE f.id = outbox_friendship_resolve.friendship_id
    AND NOT EXISTS (
      SELECT 1
      FROM vibetype.account_block ab
      WHERE (ab.created_by = f.account_a_id AND ab.blocked_account_id = f.account_b_id)
        OR (ab.created_by = f.account_b_id AND ab.blocked_account_id = f.account_a_id)
    );
$$;

COMMENT ON FUNCTION vibetype_private.outbox_friendship_resolve(UUID) IS 'Returns the data that notifications about a `friendship` outbox event need, depending on the friendship''s current status, which is returned as well: a request notifies the requested account, an acceptance the requester. Returns no row if the friendship is gone or one of its accounts blocked the other. The recipient''s language is the one of the contact the recipient keeps of itself and may be missing.';

GRANT EXECUTE ON FUNCTION vibetype_private.outbox_friendship_resolve(UUID) TO :role_service_vibetype_username;

COMMIT;
