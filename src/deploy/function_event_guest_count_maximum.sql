BEGIN;

CREATE FUNCTION vibetype.event_guest_count_maximum(event_id uuid) RETURNS integer
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT e.guest_count_maximum
  FROM vibetype.event e
  WHERE
    e.id = event_guest_count_maximum.event_id
    AND (
      -- Event organized by invoker
      e.created_by = vibetype.invoker_account_id()
      -- Or event is accessible via policy (public, invited, etc.)
      OR EXISTS (
        SELECT 1
        FROM vibetype_private.event_policy_select() ep
        WHERE ep.id = e.id
      )
    );
$$;

COMMENT ON FUNCTION vibetype.event_guest_count_maximum(UUID) IS 'Add a function that returns the maximum guest count of an accessible event.';

GRANT EXECUTE ON FUNCTION vibetype.event_guest_count_maximum(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
