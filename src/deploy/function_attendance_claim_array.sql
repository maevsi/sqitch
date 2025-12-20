BEGIN;

CREATE FUNCTION vibetype.attendance_claim_array() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH attendance_ids AS (
    SELECT NULLIF(attendance_text, '')::UUID AS id
    FROM unnest(
      string_to_array(
        replace(btrim(current_setting('jwt.claims.attendances', true), '[]'), '"', ''),
        ','
      )
    ) AS attendance_text
    WHERE NULLIF(attendance_text, '') IS NOT NULL
  ),
  blocked_account_ids AS (
    SELECT id FROM vibetype_private.account_block_ids()
  )
  SELECT COALESCE(array_agg(a.id), ARRAY[]::UUID[])
  FROM attendance_ids ai
    JOIN vibetype.attendance a ON a.id = ai.id
    JOIN vibetype.guest g ON a.guest_id = g.id
    JOIN vibetype.event e ON g.event_id = e.id
    JOIN vibetype.contact c ON g.contact_id = c.id
  WHERE NOT EXISTS (
      SELECT 1 FROM blocked_account_ids b WHERE b.id = e.created_by
    )
    AND NOT EXISTS (
      SELECT 1 FROM blocked_account_ids b WHERE b.id = c.created_by
    )
    AND (
      c.account_id IS NULL
      OR
      NOT EXISTS (
        SELECT 1 FROM blocked_account_ids b WHERE b.id = c.account_id
      )
    )
$$;

COMMENT ON FUNCTION vibetype.attendance_claim_array() IS 'Returns the current attendance claims as UUID array.';

GRANT EXECUTE ON FUNCTION vibetype.attendance_claim_array() TO vibetype_account, vibetype_anonymous;

COMMIT;
