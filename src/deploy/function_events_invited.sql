BEGIN;

CREATE FUNCTION maevsi_private.events_invited()
  RETURNS TABLE(event_id uuid)
AS $$
DECLARE
  jwt_account_id UUID;
BEGIN
  jwt_account_id := maevsi.invoker_account_id();

  RETURN QUERY
  SELECT i.event_id FROM maevsi.invitation i
  WHERE
    (
      i.contact_id IN (
        SELECT id
        FROM maevsi.contact
        WHERE
          account_id = jwt_account_id
          -- The contact selection does not return rows where account_id "IS" null due to the equality comparison.
          AND
          -- contact is not a blocked user and is not authored by a user who blocked jwt_account_id
          author_account_id NOT IN (
            SELECT blocked_account_id
            FROM maevsi.account_block
            WHERE author_account_id = jwt_account_id
            UNION ALL
            SELECT author_account_id
            FROM maevsi.account_block
            WHERE blocked_account_id = jwt_account_id
          )
      )
    )
    OR i.id = ANY (maevsi.invitation_claim_array());
END
$$ LANGUAGE plpgsql STABLE STRICT SECURITY DEFINER
;

COMMENT ON FUNCTION maevsi_private.events_invited() IS 'Add a function that returns all event ids for which the invoker is invited.';

GRANT EXECUTE ON FUNCTION maevsi_private.events_invited() TO maevsi_account, maevsi_anonymous;

COMMIT;
