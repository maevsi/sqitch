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
      -- Or event is accessible (public, invited, or has claimed attendance)
      OR (
        e.visibility = 'public'
        AND (e.guest_count_maximum IS NULL OR e.guest_count_maximum > vibetype.guest_count(e.id))
        AND NOT (e.created_by = ANY(vibetype_private.account_block_ids()))
      )
      OR e.id = ANY(vibetype_private.events_invited())
      OR e.id = ANY(vibetype_private.events_with_claimed_attendance())
    );
$$;

COMMENT ON FUNCTION vibetype.event_guest_count_maximum(UUID) IS 'Add a function that returns the maximum guest count of an accessible event.';

GRANT EXECUTE ON FUNCTION vibetype.event_guest_count_maximum(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
