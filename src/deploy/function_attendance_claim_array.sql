BEGIN;

CREATE FUNCTION vibetype.attendance_claim_array() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  WITH
  _claimed_attendance_ids AS (
    SELECT json_array_elements_text(NULLIF(current_setting('jwt.claims.attendances', true), '')::json)::UUID AS id
  ),
  _blocked AS (
    SELECT vibetype_private.account_block_ids() AS ids
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

COMMENT ON FUNCTION vibetype.attendance_claim_array() IS 'Returns the current attendance claims as UUID array.';

GRANT EXECUTE ON FUNCTION vibetype.attendance_claim_array() TO vibetype_account, vibetype_anonymous;

COMMIT;
