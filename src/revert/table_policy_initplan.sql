BEGIN;

DROP POLICY account_select ON vibetype.account;
DROP POLICY address_all ON vibetype.address;
DROP POLICY attendance_insert ON vibetype.attendance;
DROP POLICY attendance_select ON vibetype.attendance;
DROP POLICY attendance_update ON vibetype.attendance;
DROP POLICY contact_insert ON vibetype.contact;
DROP POLICY contact_select ON vibetype.contact;
DROP POLICY contact_update ON vibetype.contact;
DROP POLICY event_select ON vibetype.event;
DROP POLICY friendship_existing ON vibetype.friendship;
DROP POLICY guest_delete ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;
DROP POLICY guest_select ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;

CREATE FUNCTION vibetype_private.guests_via_own_events() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  JOIN vibetype.guest g ON g.event_id = e.id
  WHERE e.created_by = vibetype.invoker_account_id();
$$;

CREATE FUNCTION vibetype_private.guests_via_own_contact() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  WHERE c.account_id = vibetype.invoker_account_id()
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.created_by);
$$;

CREATE FUNCTION vibetype_private.guests_organized_unblocked() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH _blocked AS MATERIALIZED (
    SELECT vibetype_private.contacts_blocked() AS ids
  )
  SELECT COALESCE(array_agg(g.id), ARRAY[]::UUID[])
  FROM vibetype.event e
  JOIN vibetype.guest g ON g.event_id = e.id,
  _blocked
  WHERE e.created_by = vibetype.invoker_account_id()
    AND NOT (g.contact_id = ANY (_blocked.ids));
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.guests_organized_unblocked() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_contact() TO vibetype_account, vibetype_anonymous;
GRANT EXECUTE ON FUNCTION vibetype_private.guests_via_own_events() TO vibetype_account, vibetype_anonymous;

CREATE POLICY account_select ON vibetype.account FOR SELECT
USING (
  NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = account.id)
);

CREATE POLICY address_all ON vibetype.address FOR ALL
USING (
  (
    address.created_by = vibetype.invoker_account_id()
    OR EXISTS (
      SELECT 1
      FROM vibetype.event e
      WHERE e.address_id = address.id
    )
  )
  AND
  NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = address.created_by)
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

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

CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
);

CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.events_organized()) AS e WHERE e = guest.event_id)
  AND
  COALESCE(
    vibetype.event_guest_count_maximum(guest.event_id) > vibetype.guest_count(guest.event_id),
    TRUE
  )
  AND
    EXISTS (
      SELECT 1
      FROM vibetype.contact c
      WHERE c.id = guest.contact_id
      AND c.created_by = vibetype.invoker_account_id()
      AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = c.account_id)
    )
);

CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype.attendance_claim_array()) AS ac WHERE ac = attendance.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_events()) AS g WHERE g = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_via_own_contact()) AS g WHERE g = attendance.guest_id)
);

CREATE POLICY attendance_insert ON vibetype.attendance FOR INSERT
WITH CHECK (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_organized_unblocked()) AS g WHERE g = attendance.guest_id)
);

CREATE POLICY attendance_update ON vibetype.attendance FOR UPDATE
USING (
  EXISTS (SELECT 1 FROM unnest(vibetype_private.guests_organized_unblocked()) AS g WHERE g = attendance.guest_id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype.guest_claim_array()) AS gc WHERE gc = attendance.guest_id)
);

CREATE POLICY contact_select ON vibetype.contact FOR SELECT
USING (
  (
    contact.account_id = vibetype.invoker_account_id()
    AND
    NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = contact.created_by)
  )
  OR
  (
    contact.created_by = vibetype.invoker_account_id()
    AND
    NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = contact.account_id)
  )
  OR EXISTS (SELECT 1 FROM vibetype.guest_contact_ids() gci WHERE gci.contact_id = contact.id)
);

CREATE POLICY contact_insert ON vibetype.contact FOR INSERT
WITH CHECK (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = contact.account_id)
);

CREATE POLICY contact_update ON vibetype.contact FOR UPDATE
USING (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = contact.account_id)
);

CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
  (
    event.visibility = 'public'
    AND (
      event.guest_count_maximum IS NULL
      OR event.guest_count_maximum > vibetype.guest_count(event.id)
    )
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = event.created_by)
  )
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.events_invited()) AS inv WHERE inv = event.id)
  OR EXISTS (SELECT 1 FROM unnest(vibetype_private.events_with_claimed_attendance()) AS att WHERE att = event.id)
);

CREATE POLICY friendship_existing ON vibetype.friendship FOR ALL
USING (
  (
    vibetype.invoker_account_id() = friendship.a_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = friendship.b_account_id)
  )
  OR
  (
    vibetype.invoker_account_id() = friendship.b_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = friendship.a_account_id)
  )
)
WITH CHECK (FALSE);

COMMIT;
