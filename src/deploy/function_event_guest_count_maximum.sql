BEGIN;

CREATE FUNCTION vibetype.event_guest_count_maximum(
  event_id UUID
) RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT guest_count_maximum
    FROM vibetype.event
    WHERE
      id = $1
      AND ( -- Copied from `event_select` POLICY.
        (
          visibility = 'public'
          AND
          (
            guest_count_maximum IS NULL
            OR
            guest_count_maximum > (vibetype.guest_count(id)) -- Using the function here is required as there would otherwise be infinite recursion.
          )
        )
        OR (
          vibetype.invoker_account_id() IS NOT NULL
          AND
          created_by = vibetype.invoker_account_id()
        )
        OR id IN (SELECT vibetype_private.events_invited())
      )
  );
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION vibetype.event_guest_count_maximum(UUID) IS 'Add a function that returns the maximum guest count of an accessible event.';

GRANT EXECUTE ON FUNCTION vibetype.event_guest_count_maximum(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
