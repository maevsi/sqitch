BEGIN;

CREATE FUNCTION maevsi.guest_claim_array()
RETURNS UUID[] AS $$
DECLARE
  _guest_ids UUID[];
  _guest_ids_unblocked UUID[] := ARRAY[]::UUID[];
  _guest_id UUID;
BEGIN
  _guest_ids := string_to_array(replace(btrim(current_setting('jwt.claims.guests', true), '[]'), '"', ''), ',')::UUID[];

  IF _guest_ids IS NOT NULL THEN
    FOREACH _guest_id IN ARRAY _guest_ids
    LOOP
      -- omit guests authored by a blocked account
      IF NOT EXISTS(
        SELECT 1
        FROM maevsi.guest g
        JOIN maevsi.contact c ON g.contact_id = c.contact_id
        JOIN maevsi.account_block b ON c.author_account_id = b.blocked_account_id
       WHERE g.id = _guest_id AND b.author_account_id = maevsi.invoker_account_id()
      ) THEN
        _guest_ids_unblocked := append_guest_array(result_guest_ids, _guest_id);
      END IF;
    END LOOP;
  END IF;
  RETURN _guest_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY INVOKER;

COMMENT ON FUNCTION maevsi.guest_claim_array() IS 'Returns the current guest claims as UUID array.';

GRANT EXECUTE ON FUNCTION maevsi.guest_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
