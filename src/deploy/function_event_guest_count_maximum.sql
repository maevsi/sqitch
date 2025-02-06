BEGIN;

CREATE FUNCTION maevsi.event_guest_count_maximum(
  event_id UUID
) RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT guest_count_maximum
    FROM maevsi.event
    WHERE
      id = event_guest_count_maximum.event_id
      AND ( -- Copied from `event_select` POLICY.
        (
          visibility = 'public'
          AND
          (
            guest_count_maximum IS NULL
            OR
            guest_count_maximum > (maevsi.guest_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
          )
        )
        OR (
          maevsi.invoker_account_id() IS NOT NULL
          AND
          created_by = maevsi.invoker_account_id()
        )
        OR id IN (SELECT maevsi_private.events_invited())
      )
  );
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_guest_count_maximum(UUID) IS 'Add a function that returns the maximum guest count of an accessible event.';

GRANT EXECUTE ON FUNCTION maevsi.event_guest_count_maximum(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
