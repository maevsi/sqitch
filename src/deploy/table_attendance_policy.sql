BEGIN;

GRANT SELECT, INSERT ON TABLE vibetype.attendance TO vibetype_account;
GRANT SELECT ON TABLE vibetype.attendance TO vibetype_anonymous;
GRANT UPDATE (checked_out) ON TABLE vibetype.attendance TO vibetype_account, vibetype_anonymous;
-- Only the organizer may set it, which `attendance_guard` enforces for guests, who may update an attendance to check out.
GRANT UPDATE (tag_serial_number) ON TABLE vibetype.attendance TO vibetype_account;

ALTER TABLE vibetype.attendance ENABLE ROW LEVEL SECURITY;

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

COMMIT;
