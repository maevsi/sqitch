BEGIN;

-- A policy that called an array helper directly, as in `unnest(helper())`,
-- made the planner run the helper to estimate the array's size and the
-- executor run it again for every reference, and it could only ever filter
-- rows that some other condition had already found. Wrapped in a scalar
-- subquery the helper runs once per reference, when a row first needs it,
-- and `column = ANY ((SELECT helper()))` can be used as an index condition,
-- so reading `guest` no longer scans the table to find the visible rows.
--
-- Checks that only exclude rows stay hashed lookups, since an index cannot
-- serve them and a large array is searched linearly by `= ANY`.
--
-- The guest policies state `A OR B OR (C AND NOT blocked)` as the equivalent
-- `(A OR B OR C) AND (NOT blocked OR A OR B)`. The first part is then exactly
-- the bitmap index condition and drops out of the filter, so an organizer's
-- rows are not each searched for in the array of all their events, and the
-- second part reaches the hashed block check first.
--
-- The `attendance` policies read `guest` as the invoker instead of through
-- arrays of guest ids. An organizer of large events has hundreds
-- of thousands of guests, which made every attendance update build such an
-- array several times.

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

DROP FUNCTION vibetype_private.guests_organized_unblocked();
DROP FUNCTION vibetype_private.guests_via_own_contact();
DROP FUNCTION vibetype_private.guests_via_own_events();

-- Make all accounts accessible by everyone.
CREATE POLICY account_select ON vibetype.account FOR SELECT
USING (
  NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = account.id)
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
  NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = address.created_by)
)
WITH CHECK (
  address.created_by = vibetype.invoker_account_id()
);

-- Display guests accessible through guest claims.
-- Display guests where the contact is the invoker account,
--   omitting contacts created by a blocked account.
-- Display guests to events organized by the invoker,
--   omitting guests with contacts pointing at or created by a blocked account.
CREATE POLICY guest_select ON vibetype.guest FOR SELECT
USING (
  (
    guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
    OR guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  )
  AND (
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = guest.contact_id)
    OR guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
  )
);

CREATE POLICY guest_update ON vibetype.guest FOR UPDATE
USING (
  (
    guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
    OR guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  )
  AND (
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = guest.contact_id)
    OR guest.id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
    OR guest.contact_id = ANY ((SELECT vibetype_private.contacts_referring_invoker())::UUID[])
  )
);

-- Only allow deletes for guests of events organized by oneself.
CREATE POLICY guest_delete ON vibetype.guest FOR DELETE
USING (
  guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
);

-- Only allow inserts for guests of events organized by oneself.
-- Only allow inserts for guests of events for which the maximum guest count is not yet reached.
-- Only allow inserts for guests for a contact that was created by oneself.
-- Do not allow inserts for guests for a contact referring a blocked account.
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
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
      AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = c.account_id)
    )
);

-- Anyone with an attendance claim can view that specific attendance.
-- Everyone else can view the attendance of the guests they can view: the
-- organizer for their events, guests via guest claims and signed-in guests
-- via a contact that refers to them.
CREATE POLICY attendance_select ON vibetype.attendance FOR SELECT
USING (
  attendance.id = ANY ((SELECT vibetype.attendance_claim_array())::UUID[])
  OR EXISTS (SELECT 1 FROM vibetype.guest g WHERE g.id = attendance.guest_id)
);

-- Only the organizer may check a guest in (insert attendance).
CREATE POLICY attendance_insert ON vibetype.attendance FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM vibetype.guest g
    WHERE g.id = attendance.guest_id
      AND g.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
      AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = g.contact_id)
  )
);

-- Organizer or the guest themself (via JWT claim) may update (e.g., check out).
CREATE POLICY attendance_update ON vibetype.attendance FOR UPDATE
USING (
  attendance.guest_id = ANY ((SELECT vibetype.guest_claim_array())::UUID[])
  OR EXISTS (
    SELECT 1
    FROM vibetype.guest g
    WHERE g.id = attendance.guest_id
      AND g.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
      AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.contacts_blocked())) AS c WHERE c = g.contact_id)
  )
);

-- 1) Display contacts referencing the invoker's account, omit contacts created by an account
--  blocked by the invoker or by an account that blocked the invoker.
-- 2) Display contacts created by the invoker's account, omit contacts referring to an account
--    blocked by the invoker or by an account that blocked the invoker.
-- 3) Display contacts for which an accessible guest exists.
CREATE POLICY contact_select ON vibetype.contact FOR SELECT
USING (
  (
    contact.account_id = vibetype.invoker_account_id()
    AND
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = contact.created_by)
  )
  OR
  (
    contact.created_by = vibetype.invoker_account_id()
    AND
    NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = contact.account_id)
  )
  OR contact.id IN (SELECT gci.contact_id FROM vibetype.guest_contact_ids() gci)
);

-- Only allow inserts for contacts created by the invoker's account.
-- Disallow inserts for contacts that refer to a blocked account.
CREATE POLICY contact_insert ON vibetype.contact FOR INSERT
WITH CHECK (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = contact.account_id)
);

-- Only allow updates for contacts created by the invoker's account.
-- No contact referring to a blocked account can be updated.
CREATE POLICY contact_update ON vibetype.contact FOR UPDATE
USING (
  contact.created_by = vibetype.invoker_account_id()
  AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = contact.account_id)
);

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events to which oneself is invited, but not by a guest created by a blocked account.
-- Only display events for which the invoker has a claimed attendance.
CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
  (
    event.visibility = 'public'
    AND (
      event.guest_count_maximum IS NULL
      OR event.guest_count_maximum > vibetype.guest_count(event.id)
    )
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = event.created_by)
  )
  OR EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.events_invited())) AS inv WHERE inv = event.id)
  OR EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.events_with_claimed_attendance())) AS att WHERE att = event.id)
);

-- Only allow interactions with friendships in which the current user is involved.
CREATE POLICY friendship_existing ON vibetype.friendship FOR ALL
USING (
  (
    vibetype.invoker_account_id() = friendship.a_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = friendship.b_account_id)
  )
  OR
  (
    vibetype.invoker_account_id() = friendship.b_account_id
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = friendship.a_account_id)
  )
)
WITH CHECK (FALSE);

COMMIT;
