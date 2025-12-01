BEGIN;

CREATE FUNCTION vibetype.events_organized()
RETURNS TABLE (event_id UUID) AS $$
  SELECT id FROM vibetype.event
  WHERE
    created_by = vibetype.invoker_account_id();
$$ LANGUAGE sql STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.events_organized() IS 'Add a function that returns all event ids for which the invoker is the creator.';

GRANT EXECUTE ON FUNCTION vibetype.events_organized() TO vibetype_account, vibetype_anonymous;

COMMIT;
