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
      g.event_id IN (SELECT vibetype.events_organized())
      and g.contact_id IN (
        SELECT id
        FROM vibetype.contact
        WHERE
          created_by NOT IN (
            SELECT id FROM vibetype_private.account_block_ids()
          )
          AND (
            account_id IS NULL
            OR
            account_id NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
          )
      )
    );
$$;

COMMENT ON FUNCTION vibetype.guest_contact_ids() IS 'Returns contact ids that are accessible through guests.';

GRANT EXECUTE ON FUNCTION vibetype.guest_contact_ids() TO vibetype_account, vibetype_anonymous;

COMMIT;
