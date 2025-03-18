BEGIN;

CREATE FUNCTION vibetype.guest_contact_ids()
RETURNS TABLE (contact_id UUID) AS $$
BEGIN
  RETURN QUERY
    -- get all contacts for guests
    SELECT guest.contact_id
    FROM vibetype.guest
    WHERE
      (
        -- that are known to the invoker
        guest.id = ANY (vibetype.guest_claim_array())
      OR
        -- or for events organized by the invoker
        guest.event_id IN (SELECT vibetype.events_organized())
      )
      AND
        -- except contacts created by a blocked account or referring to a blocked account
        guest.contact_id NOT IN (
          SELECT contact.id
          FROM vibetype.contact
          WHERE
              contact.account_id IS NULL -- TODO: evaluate if this null check is necessary
            OR
              contact.account_id IN (
                SELECT id FROM vibetype_private.account_block_ids()
              )
            OR
              contact.created_by IN (
                SELECT id FROM vibetype_private.account_block_ids()
              )
        );
END;
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION vibetype.guest_contact_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
