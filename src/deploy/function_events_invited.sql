BEGIN;

CREATE FUNCTION vibetype_private.events_invited() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- Return event IDs for events the invoker is invited to.
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(DISTINCT g.event_id), ARRAY[]::UUID[])
  FROM vibetype.guest g, _blocked
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
          AND NOT (c.created_by = ANY(_blocked.ids))
      )
      AND
      -- And the corresponding event wasn't created by a blocked account.
      EXISTS (
        SELECT 1
        FROM vibetype.event e
        WHERE e.id = g.event_id
          AND NOT (e.created_by = ANY(_blocked.ids))
      )
    );
$$;

COMMENT ON FUNCTION vibetype_private.events_invited() IS 'Returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION vibetype_private.events_invited() TO vibetype_account, vibetype_anonymous;

COMMIT;
