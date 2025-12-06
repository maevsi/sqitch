BEGIN;

CREATE FUNCTION vibetype.guest_claim_array() RETURNS uuid[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH guest_ids AS (
    SELECT unnest(
      string_to_array(
        replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''),
        ','
      )::UUID[]
    ) AS id
  ),
  blocked_account_ids AS (
    SELECT id FROM vibetype_private.account_block_ids()
  )
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM guest_ids gi
    JOIN vibetype.guest g ON g.id = gi.id
    JOIN vibetype.event e ON g.event_id = e.id
    JOIN vibetype.contact c ON g.contact_id = c.id
  WHERE NOT EXISTS (
      SELECT 1 FROM blocked_account_ids b WHERE b.id = e.created_by
    )
    AND NOT EXISTS (
      SELECT 1 FROM blocked_account_ids b WHERE b.id = c.created_by
    )
    AND NOT EXISTS (
      SELECT 1 FROM blocked_account_ids b WHERE b.id = c.account_id
    )
$$;

COMMENT ON FUNCTION vibetype.guest_claim_array() IS 'Returns the current guest claims as UUID array.';

GRANT EXECUTE ON FUNCTION vibetype.guest_claim_array() TO vibetype_account, vibetype_anonymous;

COMMIT;
