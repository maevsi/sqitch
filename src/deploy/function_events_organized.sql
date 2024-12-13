BEGIN;

CREATE FUNCTION maevsi.events_organized()
RETURNS TABLE (event_id UUID) AS $$
DECLARE
  account_id UUID;
BEGIN
  account_id := maevsi.invoker_account_id();

  RETURN QUERY
    SELECT id FROM maevsi.event
    WHERE
      account_id IS NOT NULL
      AND
      "event".author_account_id = account_id;
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.events_organized() IS 'Add a function that returns all event ids for which the invoker is the author.';

GRANT EXECUTE ON FUNCTION maevsi.events_organized() TO maevsi_account, maevsi_anonymous;

COMMIT;
