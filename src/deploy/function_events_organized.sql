BEGIN;

CREATE FUNCTION vibetype.events_organized() RETURNS TABLE(event_id uuid)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT id FROM vibetype.event
  WHERE
    created_by = vibetype.invoker_account_id();
$$;

COMMENT ON FUNCTION vibetype.events_organized() IS 'Add a function that returns all event ids for which the invoker is the creator.';

GRANT EXECUTE ON FUNCTION vibetype.events_organized() TO vibetype_account, vibetype_anonymous;

COMMIT;
