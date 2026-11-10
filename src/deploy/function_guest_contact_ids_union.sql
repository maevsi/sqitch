BEGIN;

-- The `OR` across guest claims and own events forced a sequential scan over
-- all guests that called `guest_claim_array()` once per guest row. Collecting
-- the guest ids from index-friendly branches first keeps one result row per
-- guest, as before, even when a guest matches both branches.
CREATE OR REPLACE FUNCTION vibetype.guest_contact_ids() RETURNS TABLE(contact_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  -- get all contacts of guests
  SELECT g.contact_id
  FROM vibetype.guest g
  WHERE g.id IN (
    -- that are known through a guest claim
    SELECT unnest(vibetype.guest_claim_array())
    UNION ALL
    -- or for events organized by the invoker, omitting contacts created by or pointing at a blocked account
    SELECT g_own.id
    FROM vibetype.event e
    JOIN vibetype.guest g_own ON g_own.event_id = e.id
    JOIN vibetype.contact c ON c.id = g_own.contact_id,
    _blocked
    WHERE e.created_by = vibetype.invoker_account_id()
      AND NOT (c.created_by = ANY (_blocked.ids))
      AND (c.account_id IS NULL OR NOT (c.account_id = ANY (_blocked.ids)))
  );
$$;

COMMIT;
