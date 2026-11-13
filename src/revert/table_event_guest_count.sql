BEGIN;

DROP POLICY guest_insert ON vibetype.guest;
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

DROP POLICY event_select ON vibetype.event;
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

CREATE OR REPLACE FUNCTION vibetype.event_guest_count_maximum(event_id uuid) RETURNS integer
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT e.guest_count_maximum
  FROM vibetype.event e
  WHERE
    e.id = event_guest_count_maximum.event_id
    AND (
      -- Event organized by invoker
      e.created_by = vibetype.invoker_account_id()
      -- Or event is accessible (public, invited, or has claimed attendance)
      OR (
        e.visibility = 'public'
        AND (e.guest_count_maximum IS NULL OR e.guest_count_maximum > vibetype.guest_count(e.id))
        AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = e.created_by)
      )
      OR e.id = ANY(vibetype_private.events_invited())
      OR e.id = ANY(vibetype_private.events_with_claimed_attendance())
    );
$$;

DROP TRIGGER guest_count_delete ON vibetype.guest;
DROP TRIGGER guest_count_insert ON vibetype.guest;
DROP FUNCTION vibetype_private.trigger_guest_count_delete();
DROP FUNCTION vibetype_private.trigger_guest_count_insert();

REVOKE INSERT, UPDATE ON TABLE vibetype.event FROM vibetype_account;
GRANT INSERT, UPDATE ON TABLE vibetype.event TO vibetype_account;

ALTER TABLE vibetype.event DROP COLUMN guest_count;

COMMIT;
