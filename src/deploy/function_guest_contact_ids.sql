BEGIN;

CREATE FUNCTION vibetype.guest_contact_ids() RETURNS TABLE(contact_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
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
          FROM vibetype.contact c
          WHERE c.id = g.contact_id
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.created_by
          )
          AND NOT EXISTS (
            SELECT 1 FROM vibetype_private.account_block_ids() b WHERE b.id = c.account_id
          )
        )
      )
    );
$$;

COMMENT ON FUNCTION vibetype.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION vibetype.guest_contact_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
