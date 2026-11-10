BEGIN;

-- Splitting the `OR` into a `UNION ALL` lets each branch use an index instead
-- of a sequential scan over all guests, which called `guest_claim_array()` and
-- `account_block_ids()` once per guest row. `MATERIALIZED` keeps `_blocked`
-- from being inlined, which would also repeat `account_block_ids()` per row.
CREATE OR REPLACE FUNCTION vibetype_private.events_invited() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  -- Return event IDs for events the invoker is invited to.
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(DISTINCT invited.event_id), ARRAY[]::UUID[])
  FROM (
    -- Guest records explicitly known to the invoker (via guest claim).
    SELECT g.event_id
    FROM vibetype.guest g
    WHERE g.id = ANY (vibetype.guest_claim_array())
    UNION ALL
    -- Guest whose contact belongs to the invoker, with neither the contact nor the event created by a blocked account.
    SELECT g.event_id
    FROM vibetype.contact c
    JOIN vibetype.guest g ON g.contact_id = c.id
    JOIN vibetype.event e ON e.id = g.event_id,
    _blocked
    WHERE c.account_id = vibetype.invoker_account_id()
      AND NOT (c.created_by = ANY (_blocked.ids))
      AND NOT (e.created_by = ANY (_blocked.ids))
  ) invited;
$$;

COMMIT;
