BEGIN;

CREATE FUNCTION vibetype_private.events_invited() RETURNS TABLE(event_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- Return event IDs for events the invoker is invited to.
  SELECT g.event_id FROM vibetype.guest g
  WHERE
      -- Guest records explicitly known to the invoker (via guest claim).
      g.id = ANY (vibetype.guest_claim_array())
    OR
    (
      -- Guest whose contact belongs to the invoker and the contact wasn't created by a blocked account.
      EXISTS (
        SELECT 1
        FROM vibetype.contact c
        WHERE c.id = g.contact_id
          AND c.account_id = vibetype.invoker_account_id()
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
          )
      )
      AND
      -- And the corresponding event wasn't created by a blocked account.
      EXISTS (
        SELECT 1
        FROM vibetype.event e
        WHERE e.id = g.event_id
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = e.created_by
          )
      )
    );
$$;

COMMENT ON FUNCTION vibetype_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION vibetype_private.events_invited() TO vibetype_account, vibetype_anonymous;

COMMIT;
