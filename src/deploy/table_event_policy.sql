BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

GRANT SELECT ON TABLE vibetype.event TO vibetype_anonymous;
GRANT SELECT, DELETE ON TABLE vibetype.event TO vibetype_account;
-- Column level grants in place of table level ones, so that `guest_count` is the only column not writable.
-- `guest.event_id` is not updatable (no column grant, and `trigger_guest_update` rejects it), so only inserts and deletes of guests move the counter.
GRANT INSERT (
  id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote,
  language, name, slug, start, url, visibility, created_at, created_by
) ON TABLE vibetype.event TO vibetype_account;
GRANT UPDATE (
  id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote,
  language, name, slug, start, url, visibility, created_at, created_by
) ON TABLE vibetype.event TO vibetype_account;
GRANT SELECT ON TABLE vibetype.event TO :role_service_reccoom_username;

ALTER TABLE vibetype.event ENABLE ROW LEVEL SECURITY;

-- Only allow events that are organized by oneself.
CREATE POLICY event_all ON vibetype.event FOR ALL
USING (
  created_by = vibetype.invoker_account_id()
);

-- Only display events that are public and not full and not organized by a blocked account.
-- Only display events to which oneself is invited, but not by a guest created by a blocked account.
-- Only display events for which the invoker has a claimed attendance.

-- Helper: returns event IDs for events accessible through attendance claims.
-- Needs SECURITY DEFINER to bypass RLS on attendance and guest tables.
CREATE FUNCTION vibetype_private.events_with_claimed_attendance() RETURNS UUID[]
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT COALESCE(array_agg(DISTINCT g.event_id), ARRAY[]::UUID[])
  FROM vibetype.attendance a
  JOIN vibetype.guest g ON g.id = a.guest_id
  WHERE a.id = ANY (vibetype.attendance_claim_array());
$$;

GRANT EXECUTE ON FUNCTION vibetype_private.events_with_claimed_attendance() TO vibetype_account, vibetype_anonymous;

CREATE POLICY event_select ON vibetype.event FOR SELECT
USING (
  (
    event.visibility = 'public'
    AND (
      event.guest_count_maximum IS NULL
      OR event.guest_count_maximum > event.guest_count
    )
    AND NOT EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.account_block_ids())) AS b WHERE b = event.created_by)
  )
  OR EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.events_invited())) AS inv WHERE inv = event.id)
  OR EXISTS (SELECT 1 FROM unnest((SELECT vibetype_private.events_with_claimed_attendance())) AS att WHERE att = event.id)
);

COMMIT;
