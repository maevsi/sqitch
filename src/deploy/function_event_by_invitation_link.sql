BEGIN;

-- SECURITY DEFINER: holding the link's code is what grants access, so a private event is returned without passing `event_select`.
CREATE FUNCTION vibetype.event_by_invitation_link(invitation_link_id UUID) RETURNS vibetype.event
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT e.*
  FROM vibetype.event_invitation_link l
  JOIN vibetype.event e ON e.id = l.event_id
  WHERE l.id = event_by_invitation_link.invitation_link_id
    AND (e.published_at <= CURRENT_TIMESTAMP OR e.created_by = vibetype.invoker_account_id())
    AND e.created_by <> ALL (vibetype_private.account_block_ids());
$$;

COMMENT ON FUNCTION vibetype.event_by_invitation_link(UUID) IS 'Returns the event a general invitation link invites to, also when it is private, unless the link was deleted, the event is a draft or scheduled and not organized by the invoker, or its organizer is involved in a block with the invoker.';

GRANT EXECUTE ON FUNCTION vibetype.event_by_invitation_link(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
