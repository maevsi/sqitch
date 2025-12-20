BEGIN;

-- TODO: remove once views are introduced that allow guest ids to be public

CREATE FUNCTION vibetype.event_by_attendance_id(attendance_id uuid) RETURNS vibetype.event
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT e.*
  FROM vibetype.event e
  JOIN vibetype.guest g ON g.event_id = e.id
  JOIN vibetype.attendance a ON a.guest_id = g.id
  WHERE a.id = event_by_attendance_id.attendance_id
$$;

COMMENT ON FUNCTION vibetype.event_by_attendance_id(UUID) IS 'Returns the event associated with the given attendance ID.';

GRANT EXECUTE ON FUNCTION vibetype.event_by_attendance_id(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
