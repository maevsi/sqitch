BEGIN;

CREATE FUNCTION vibetype.guest_claim_array() RETURNS uuid[]
    LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
    AS $$
DECLARE
  _guest_ids UUID[];
  _guest_ids_unblocked UUID[] := ARRAY[]::UUID[];
BEGIN
  _guest_ids := string_to_array(replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''), ',')::UUID[];

  IF _guest_ids IS NOT NULL THEN
    _guest_ids_unblocked := ARRAY (
      SELECT g.id
      FROM vibetype.guest g
        JOIN vibetype.event e ON g.event_id = e.id
        JOIN vibetype.contact c ON g.contact_id = c.id
      WHERE g.id = ANY(_guest_ids)
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
        )
        AND NOT EXISTS (
          SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
        )
    );
  ELSE
    _guest_ids_unblocked := ARRAY[]::UUID[];
  END IF;
  RETURN _guest_ids_unblocked;
END
$$;

COMMENT ON FUNCTION vibetype.guest_claim_array() IS 'Returns the current guest claims as UUID array.';

GRANT EXECUTE ON FUNCTION vibetype.guest_claim_array() TO vibetype_account, vibetype_anonymous;

COMMIT;
