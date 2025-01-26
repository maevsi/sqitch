BEGIN;

CREATE FUNCTION maevsi.invitation_claim_array()
RETURNS UUID[] AS $$
DECLARE
  _invitation_ids UUID[];
  _invitation_ids_unblocked UUID[] := ARRAY[]::UUID[];
BEGIN
  _invitation_ids := string_to_array(replace(btrim(current_setting('jwt.claims.invitations', true), '[]'), '"', ''), ',')::UUID[];

  IF _invitation_ids IS NOT NULL THEN
    _invitation_ids_unblocked := ARRAY (
      SELECT i.id
      FROM maevsi.invitation i
        JOIN maevsi.event e ON i.event_id = e.id
        JOIN maevsi.contact c ON i.contact_id = c.id
      WHERE i.id = ANY(_invitation_ids)
        AND e.author_account_id NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
        AND (
          c.author_account_id NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
          AND (
            c.account_id IS NULL
            OR
            c.account_id NOT IN (
              SELECT id FROM maevsi_private.account_block_ids()
            )
          )
        )
    );
  ELSE
    _invitation_ids_unblocked := ARRAY[]::UUID[];
  END IF;
  RETURN _invitation_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.invitation_claim_array() IS 'Returns the current invitation claims as UUID array.';

GRANT EXECUTE ON FUNCTION maevsi.invitation_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
