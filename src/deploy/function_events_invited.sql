BEGIN;

CREATE FUNCTION vibetype_private.events_invited()
RETURNS TABLE(event_id uuid) AS $$
BEGIN
  RETURN QUERY

  -- get all events for guests
  SELECT guest.event_id FROM vibetype.guest
  WHERE
    (
      -- whose guest
      guest.contact_id IN (
        SELECT id
        FROM vibetype.contact
        WHERE
            -- is the requesting user
            account_id = vibetype.invoker_account_id() -- if the invoker account id is `NULL` this does *not* return contacts for which `account_id` is NULL (an `IS` instead of `=` comparison would)
          AND
            -- who is not invited by
            created_by NOT IN (
              SELECT id FROM vibetype_private.account_block_ids()
            )
      ) -- TODO: it appears blocking should be accounted for after all other criteria using the event author instead
    )
    OR
      -- for which the requesting user knows the id
      guest.id = ANY (vibetype.guest_claim_array());
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER;

COMMENT ON FUNCTION vibetype_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION vibetype_private.events_invited() TO vibetype_account, vibetype_anonymous;

COMMIT;
