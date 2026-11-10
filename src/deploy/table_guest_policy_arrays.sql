BEGIN;

-- `guest_row_visible(contact_id, event_id)` ran once for every guest row the
-- array checks rejected, which is nearly the whole table on an unfiltered
-- read. These helpers read only `contact` and `event`, so the arrays also
-- cover a guest inserted by the current statement (INSERT ... RETURNING) and
-- the per-row fallback is no longer needed.

-- Helper: returns contact IDs referring to the invoker's account, omitting contacts created by a blocked account.
-- Needs SECURITY DEFINER to bypass RLS on the contact table.
CREATE FUNCTION vibetype_private.contacts_referring_invoker() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(c.id), ARRAY[]::UUID[])
  FROM vibetype.contact c
  WHERE c.account_id = vibetype.invoker_account_id()
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.created_by);
$$;

-- Helper: returns contact IDs created by or pointing at a blocked account.
-- Needs SECURITY DEFINER to bypass RLS on the contact table.
CREATE FUNCTION vibetype_private.contacts_blocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
  )
  SELECT COALESCE(array_agg(c.id), ARRAY[]::UUID[])
  FROM vibetype.contact c, _blocked
  WHERE c.created_by = ANY (_blocked.ids)
    OR c.account_id = ANY (_blocked.ids);
$$;

-- Helper: returns event IDs for events organized by the invoker.
-- Needs SECURITY DEFINER to skip the event policies, which would otherwise be evaluated for every own event.
CREATE FUNCTION vibetype_private.events_organized() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(e.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.contacts_blocked() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.contacts_referring_invoker() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.events_organized() TO vibetype_account, vibetype_anonymous;

DROP POLICY guest_select ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;

-- Display guests accessible through guest claims.
-- Display guests where the contact is the invoker account,
--   omitting contacts created by a blocked account.
-- Display guests to events organized by the invoker,
--   omitting guests with contacts pointing at or created by a blocked account.
CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.contacts_referring_invoker()) AS c WHERE c = guest.contact_id)
  OR (
    EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.contacts_blocked()) AS c WHERE c = guest.contact_id)
  )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = guest.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.contacts_referring_invoker()) AS c WHERE c = guest.contact_id)
  OR (
    EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.contacts_blocked()) AS c WHERE c = guest.contact_id)
  )
);

DROP FUNCTION vibetype_private.guest_row_visible(UUID, UUID);
DROP FUNCTION vibetype_private.guests_via_own_events_unblocked();

COMMIT;
