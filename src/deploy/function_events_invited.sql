BEGIN;

CREATE FUNCTION maevsi_private.events_invited()
RETURNS TABLE(event_id uuid) AS $$
BEGIN
  RETURN QUERY

  -- get all events for guests
  SELECT g.event_id FROM maevsi.guest g
  WHERE
    (
      -- whose event ...
      g.event_id IN (
        SELECT id
        FROM maevsi.event
        WHERE
          -- is not created by ...
          created_by NOT IN (
            SELECT id FROM maevsi_private.account_block_ids()
          )
      )
      AND
      -- whose invitee
      g.contact_id IN (
        SELECT id
        FROM maevsi.contact
        WHERE
            -- is the requesting user
            account_id = maevsi.invoker_account_id()
          AND
            -- who is not invited by
            created_by NOT IN (
              SELECT id FROM maevsi_private.account_block_ids()
            )
      )
    )
    OR
      -- for which the requesting user knows the id
      g.id = ANY (maevsi.guest_claim_array());
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION maevsi_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION maevsi_private.events_invited() TO maevsi_account, maevsi_anonymous;

COMMIT;
