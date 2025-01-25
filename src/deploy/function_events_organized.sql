BEGIN;

CREATE FUNCTION maevsi.events_organized()
RETURNS TABLE (event_id UUID) AS $$
BEGIN

  RETURN QUERY
    SELECT id FROM maevsi.event
    WHERE
      author_account_id = maevsi.invoker_account_id();
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.events_organized() IS 'Add a function that returns all event ids for which the invoker is the author.';

GRANT EXECUTE ON FUNCTION maevsi.events_organized() TO maevsi_account, maevsi_anonymous;

COMMIT;
