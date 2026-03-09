BEGIN;

CREATE FUNCTION vibetype.guest_contact_ids() RETURNS TABLE(contact_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  -- get all contacts of guests
  SELECT g.contact_id
  FROM vibetype.guest g
  WHERE
    (
      -- that are known through a guest claim
      g.id = ANY (vibetype.guest_claim_array())
    OR
      -- or for events organized by the invoker
      (
        EXISTS (
          SELECT 1
          FROM vibetype.event e
          WHERE e.id = g.event_id
            AND e.created_by = vibetype.invoker_account_id()
        )
        AND
        EXISTS (
          SELECT 1
          FROM vibetype.contact c, _blocked
          WHERE c.id = g.contact_id
            AND NOT (c.created_by = ANY(_blocked.ids))
            AND (c.account_id IS NULL OR NOT (c.account_id = ANY(_blocked.ids)))
        )
      )
    );
$$;

COMMENT ON FUNCTION vibetype.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION vibetype.guest_contact_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
