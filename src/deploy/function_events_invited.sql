BEGIN;

-- TODO: compare to guest_select, guest_update policy
CREATE FUNCTION vibetype_private.events_invited() RETURNS TABLE(event_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- get all events for guests
  SELECT g.event_id FROM vibetype.guest g
  WHERE
    (
      -- whose event ...
      g.event_id IN (
        SELECT id
        FROM vibetype.event
        WHERE
          -- is not created by ...
          created_by NOT IN (
            SELECT id FROM vibetype_private.account_block_ids()
          )
      )
      AND
      -- whose invitee
      g.contact_id IN (
        SELECT id
        FROM vibetype.contact
        WHERE
            -- is the requesting user
            account_id = vibetype.invoker_account_id()
          AND
            -- who is not invited by
            created_by NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
      )
    )
    OR
      -- for which the requesting user knows the id
      g.id = ANY (vibetype.guest_claim_array());
$$;

COMMENT ON FUNCTION vibetype_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION vibetype_private.events_invited() TO vibetype_account, vibetype_anonymous;

COMMIT;
