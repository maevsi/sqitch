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
      EXISTS (
        SELECT 1
        FROM vibetype.event e
        WHERE e.id = g.event_id
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
          )
      )
      AND
      -- whose invitee
      EXISTS (
        SELECT 1
        FROM vibetype.contact c
        WHERE c.id = g.contact_id
          AND c.account_id = vibetype.invoker_account_id()
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
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
