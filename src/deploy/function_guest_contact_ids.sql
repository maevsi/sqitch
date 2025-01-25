BEGIN;

CREATE FUNCTION maevsi.guest_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    -- get all contacts for guests
    SELECT guest.contact_id
    FROM maevsi.guest
    WHERE
      (
        -- that are known to the invoker
        guest.id = ANY (maevsi.guest_claim_array())
      OR
        -- or for events organized by the invoker
        guest.event_id IN (SELECT maevsi.events_organized())
      )
      AND
        -- except contacts authored by a blocked account or referring to a blocked account
        guest.contact_id NOT IN (
          SELECT contact.id
          FROM maevsi.contact
          WHERE
              contact.account_id IS NULL -- TODO: evaluate if this null check is necessary
            OR
              contact.account_id IN (
                SELECT id FROM maevsi_private.account_block_ids()
              )
            OR
              contact.author_account_id IN (
                SELECT id FROM maevsi_private.account_block_ids()
              )
        );
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION maevsi.guest_contact_ids() TO maevsi_account, maevsi_anonymous;

COMMIT;
