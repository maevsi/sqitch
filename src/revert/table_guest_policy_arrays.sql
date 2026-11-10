BEGIN;

CREATE FUNCTION vibetype_private.guests_via_own_events_unblocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.guest g
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.contact c ON c.id = g.contact_id,
  _blocked
  WHERE e.created_by = vibetype.invoker_account_id()
    AND (c.account_id IS NULL OR NOT (c.account_id = ANY(_blocked.ids)))
    AND NOT (c.created_by = ANY(_blocked.ids));
$$;

CREATE FUNCTION vibetype_private.guest_row_visible(contact_id UUID, event_id UUID) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT (
    EXISTS (
      SELECT 1
      FROM vibetype.contact c, _blocked
      WHERE c.id = guest_row_visible.contact_id
        AND c.account_id = vibetype.invoker_account_id()
        AND NOT (c.created_by = ANY(_blocked.ids))
    )
    OR (
      EXISTS (
        SELECT 1
        FROM vibetype.event e
        WHERE e.id = guest_row_visible.event_id
          AND e.created_by = vibetype.invoker_account_id()
      )
      AND EXISTS (
        SELECT 1
        FROM vibetype.contact c, _blocked
        WHERE c.id = guest_row_visible.contact_id
          AND (c.account_id IS NULL OR NOT (c.account_id = ANY(_blocked.ids)))
          AND NOT (c.created_by = ANY(_blocked.ids))
      )
    )
  );
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_events_unblocked() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.guest_row_visible(UUID, UUID) TO vibetype_account, vibetype_anonymous;

DROP POLICY guest_select ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;

CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events_unblocked()) AS g WHERE g = guest.id)
  OR vibetype_private.guest_row_visible(guest.contact_id, guest.event_id)
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events_unblocked()) AS g WHERE g = guest.id)
  OR vibetype_private.guest_row_visible(guest.contact_id, guest.event_id)
);

DROP FUNCTION vibetype_private.contacts_blocked();
DROP FUNCTION vibetype_private.contacts_referring_invoker();
DROP FUNCTION vibetype_private.events_organized();

COMMIT;
