BEGIN;

CREATE FUNCTION vibetype.guest_claim_array() RETURNS uuid[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH
  _claimed_guest_ids AS (
    SELECT json_array_elements_text(NULLIF(current_setting('jwt.claims.guests', true), '')::json)::UUID AS id
  ),
  _blocked_accounts AS (
    SELECT id FROM vibetype_private.account_block_ids()
  ),
  _accessible_guests AS (
    SELECT guest.id
    FROM _claimed_guest_ids claimed
    INNER JOIN vibetype.guest ON guest.id = claimed.id
    INNER JOIN vibetype.event ON event.id = guest.event_id
    INNER JOIN vibetype.contact ON contact.id = guest.contact_id
    WHERE NOT EXISTS (SELECT 1 FROM _blocked_accounts WHERE id = event.created_by)
      AND NOT EXISTS (SELECT 1 FROM _blocked_accounts WHERE id = contact.created_by)
      AND (contact.account_id IS NULL OR NOT EXISTS (SELECT 1 FROM _blocked_accounts WHERE id = contact.account_id))
  )
  SELECT COALESCE(array_agg(id), ARRAY[]::UUID[])
  FROM _accessible_guests;
$$;

COMMENT ON FUNCTION vibetype.guest_claim_array() IS 'Returns the current guest claims as UUID array.';

GRANT EXECUTE ON FUNCTION vibetype.guest_claim_array() TO vibetype_account, vibetype_anonymous;

COMMIT;
