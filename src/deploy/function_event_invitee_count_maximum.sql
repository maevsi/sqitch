BEGIN;

CREATE FUNCTION maevsi.event_invitee_count_maximum(
  event_id UUID
) RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT invitee_count_maximum
    FROM maevsi.event e
    WHERE
      e.id = $1
      AND ( -- Copied from `event_select` POLICY.
        (
          e.visibility = 'public'
          AND
          (
            e.invitee_count_maximum IS NULL
            OR
            e.invitee_count_maximum > (maevsi.invitee_count(e.id)) -- Using the function here is required as there would otherwise be infinite recursion.
          )
        )
        OR (
          maevsi.invoker_account_id() IS NOT NULL
          AND
          e.author_account_id = maevsi.invoker_account_id()
        )
        OR e.id IN (SELECT maevsi_private.events_invited())
      )
  );
END
$$ LANGUAGE PLPGSQL STRICT STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.event_invitee_count_maximum(UUID) IS 'Add a function that returns the maximum invitee count of an accessible event.';

GRANT EXECUTE ON FUNCTION maevsi.event_invitee_count_maximum(UUID) TO maevsi_account, maevsi_anonymous;

COMMIT;
