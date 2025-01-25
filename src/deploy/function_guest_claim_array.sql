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
      -- omit guests of events authored by an account blocked by the current user
      IF EXISTS (
	      SELECT 1
	      FROM maevsi.guest i
	        JOIN maevsi.event e ON i.event_id = e.id
	      WHERE i.id = _guest_id AND e.author_account_id NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
	    ) THEN
        _guest_ids_unblocked := array_append(_guest_ids_unblocked, _guest_id);
	    END IF;
    END LOOP;
  END IF;
  RETURN _guest_ids_unblocked;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY INVOKER;

COMMENT ON FUNCTION maevsi.guest_claim_array() IS 'Returns the current guest claims as UUID array.';

GRANT EXECUTE ON FUNCTION maevsi.guest_claim_array() TO maevsi_account, maevsi_anonymous;

COMMIT;
