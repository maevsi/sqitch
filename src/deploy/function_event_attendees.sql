BEGIN;

-- Needs SECURITY DEFINER to bypass RLS on the guest and contact tables, which only show a guest to its organizer and to itself.
-- An acceptance only counts if the guest's own account made the last change, as the organizer can set a guest's feedback too and must not be able to list an account as attending.
CREATE FUNCTION vibetype_private.event_attendee_account_ids(event_id uuid) RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT COALESCE(array_agg(DISTINCT c.account_id), ARRAY[]::UUID[])
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  WHERE g.event_id = event_attendee_account_ids.event_id
    AND g.feedback = 'accepted'::vibetype.invitation_feedback
    AND NOT g.is_ghost
    AND g.updated_by = c.account_id
    AND NOT (c.account_id = ANY (vibetype_private.account_block_ids()));
$$;

COMMENT ON FUNCTION vibetype_private.event_attendee_account_ids(UUID) IS 'Returns the ids of the accounts that accepted to take part in an event themselves and are not in ghost mode, omitting accounts involved in a block with the invoker.';

GRANT EXECUTE ON FUNCTION vibetype_private.event_attendee_account_ids(UUID) TO vibetype_account;

-- The body is SQL-standard, so it is resolved at creation and accounts need no access to the private schema.
CREATE FUNCTION vibetype.event_attendees(event vibetype.event) RETURNS SETOF vibetype.account
    LANGUAGE sql STABLE STRICT SECURITY INVOKER
BEGIN ATOMIC
  SELECT a.*
  FROM vibetype.account a
  WHERE a.id = ANY (vibetype_private.event_attendee_account_ids((event).id))
    -- the event's select policy decides, not the passed row, which could be made up
    AND EXISTS (SELECT 1 FROM vibetype.event e WHERE e.id = (event).id);
END;

COMMENT ON FUNCTION vibetype.event_attendees(vibetype.event) IS 'The accounts that accepted to take part in the event and are not in ghost mode. Visible to every account that can see the event.';

GRANT EXECUTE ON FUNCTION vibetype.event_attendees(vibetype.event) TO vibetype_account;

COMMIT;
