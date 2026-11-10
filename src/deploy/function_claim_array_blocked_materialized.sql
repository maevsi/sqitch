BEGIN;

-- `MATERIALIZED` keeps `_blocked` from being inlined, which would call
-- `account_block_ids()` once per claimed row instead of once per call. The
-- `EXISTS` skips that call when there are no claims, which is the common case.

CREATE OR REPLACE FUNCTION vibetype.attendance_claim_array() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH
  _claimed_attendance_ids AS (
    SELECT json_array_elements_text(NULLIF(current_setting('jwt.claims.attendances', true), '')::json)::UUID AS id
  ),
  _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
    WHERE EXISTS (SELECT 1 FROM _claimed_attendance_ids)
  ),
  _accessible_attendances AS (
    SELECT attendance.id
    FROM _claimed_attendance_ids claimed
    INNER JOIN vibetype.attendance ON attendance.id = claimed.id
    INNER JOIN vibetype.guest ON guest.id = attendance.guest_id
    INNER JOIN vibetype.event ON event.id = guest.event_id
    INNER JOIN vibetype.contact ON contact.id = guest.contact_id,
    _blocked
    WHERE NOT (event.created_by = ANY(_blocked.ids))
      AND NOT (contact.created_by = ANY(_blocked.ids))
      AND (contact.account_id IS NULL OR NOT (contact.account_id = ANY(_blocked.ids)))
  )
  SELECT COALESCE(array_agg(id), ARRAY[]::UUID[])
  FROM _accessible_attendances;
$$;

CREATE OR REPLACE FUNCTION vibetype.guest_claim_array() RETURNS uuid[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH
  _claimed_guest_ids AS (
    SELECT json_array_elements_text(NULLIF(current_setting('jwt.claims.guests', true), '')::json)::UUID AS id
  ),
  _blocked AS MATERIALIZED (
    SELECT vibetype_private.account_block_ids() AS ids
    WHERE EXISTS (SELECT 1 FROM _claimed_guest_ids)
  ),
  _accessible_guests AS (
    SELECT guest.id
    FROM _claimed_guest_ids claimed
    INNER JOIN vibetype.guest ON guest.id = claimed.id
    INNER JOIN vibetype.event ON event.id = guest.event_id
    INNER JOIN vibetype.contact ON contact.id = guest.contact_id,
    _blocked
    WHERE NOT (event.created_by = ANY(_blocked.ids))
      AND NOT (contact.created_by = ANY(_blocked.ids))
      AND (contact.account_id IS NULL OR NOT (contact.account_id = ANY(_blocked.ids)))
  )
  SELECT COALESCE(array_agg(id), ARRAY[]::UUID[])
  FROM _accessible_guests;
$$;

COMMIT;
