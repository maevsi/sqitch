BEGIN;

CREATE FUNCTION maevsi.guest_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    -- get all contacts of guests
    SELECT g.contact_id
    FROM maevsi.guest g
    WHERE
      (
        -- that are known through a guest claim
        g.id = ANY (maevsi.guest_claim_array())
      OR
        -- or for events organized by the invoker
        g.event_id IN (SELECT maevsi.events_organized())
        and g.contact_id IN (
          SELECT id
          FROM maevsi.contact
          WHERE
            created_by NOT IN (
              SELECT id FROM maevsi_private.account_block_ids()
            )
            AND (
              account_id IS NULL
              OR
              account_id NOT IN (
                SELECT id FROM maevsi_private.account_block_ids()
              )
            )
        )
      );
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION maevsi.guest_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
