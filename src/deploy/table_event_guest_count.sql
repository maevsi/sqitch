BEGIN;

-- `guest_count()` is a security definer function, so an inline subquery on `guest` in the `event_select` policy would run under guest row level security and undercount (anonymous would see 0).
-- A counter on the event is read like any other column, needs no function call per row, and is kept exact by the triggers below.
ALTER TABLE vibetype.event ADD COLUMN guest_count INTEGER NOT NULL DEFAULT 0;

-- Block writes to guest until commit so no guest is added or removed between the backfill and the triggers.
LOCK TABLE vibetype.guest IN SHARE ROW EXCLUSIVE MODE;

UPDATE vibetype.event
SET guest_count = g.guest_count
FROM (
  SELECT event_id, COUNT(*)::INTEGER AS guest_count
  FROM vibetype.guest
  GROUP BY event_id
) g
WHERE event.id = g.event_id;

COMMENT ON COLUMN vibetype.event.guest_count IS E'@behavior -insert -update\nThe number of guests of the event, maintained by triggers on the guest table.';

-- Column level grants in place of the table level ones, so that `guest_count` is the only column not writable.
-- `guest.event_id` is not updatable (no column grant, and `trigger_guest_update` rejects it), so only inserts and deletes of guests move the counter.
REVOKE INSERT, UPDATE ON TABLE vibetype.event FROM vibetype_account;
GRANT INSERT (
  id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote,
  language, name, slug, start, url, visibility, created_at, created_by
) ON TABLE vibetype.event TO vibetype_account;
GRANT UPDATE (
  id, address_id, description, "end", guest_count_maximum, is_archived, is_in_person, is_remote,
  language, name, slug, start, url, visibility, created_at, created_by
) ON TABLE vibetype.event TO vibetype_account;

-- Security definer because guest inserters have no update privilege on event.
-- The events are locked in id order before they are updated, so concurrent statements touching several of the same events cannot deadlock.
-- A statement level trigger on a transition table updates every affected event once, even when a cascade removes many guests.
CREATE FUNCTION vibetype_private.trigger_guest_count_insert() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog
    AS $$
BEGIN
  PERFORM 1
  FROM vibetype.event
  WHERE id IN (SELECT event_id FROM guest_inserted)
  ORDER BY id
  FOR UPDATE;

  UPDATE vibetype.event
  SET guest_count = event.guest_count + g.guest_count
  FROM (
    SELECT event_id, COUNT(*)::INTEGER AS guest_count
    FROM guest_inserted
    GROUP BY event_id
  ) g
  WHERE event.id = g.event_id;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_guest_count_insert() IS 'Adds the guests of an insert statement to the guest count of their events.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_guest_count_insert() FROM PUBLIC;

CREATE FUNCTION vibetype_private.trigger_guest_count_delete() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog
    AS $$
BEGIN
  PERFORM 1
  FROM vibetype.event
  WHERE id IN (SELECT event_id FROM guest_deleted)
  ORDER BY id
  FOR UPDATE;

  UPDATE vibetype.event
  SET guest_count = event.guest_count - g.guest_count
  FROM (
    SELECT event_id, COUNT(*)::INTEGER AS guest_count
    FROM guest_deleted
    GROUP BY event_id
  ) g
  WHERE event.id = g.event_id;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_guest_count_delete() IS 'Subtracts the guests of a delete statement from the guest count of their events.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_guest_count_delete() FROM PUBLIC;

CREATE TRIGGER guest_count_insert
  AFTER INSERT
  ON vibetype.guest
  REFERENCING NEW TABLE AS guest_inserted
  FOR EACH STATEMENT
  EXECUTE FUNCTION vibetype_private.trigger_guest_count_insert();

CREATE TRIGGER guest_count_delete
  AFTER DELETE
  ON vibetype.guest
  REFERENCING OLD TABLE AS guest_deleted
  FOR EACH STATEMENT
  EXECUTE FUNCTION vibetype_private.trigger_guest_count_delete();

CREATE OR REPLACE FUNCTION vibetype.event_guest_count_maximum(event_id uuid) RETURNS integer
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
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
        AND (e.guest_count_maximum IS NULL OR e.guest_count_maximum > e.guest_count)
        AND NOT EXISTS (SELECT 1 FROM unnest(vibetype_private.account_block_ids()) AS b WHERE b = e.created_by)
      )
      OR e.id = ANY(vibetype_private.events_invited())
      OR e.id = ANY(vibetype_private.events_with_claimed_attendance())
    );
$$;

DROP POLICY event_select ON vibetype.event;
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

-- The counter is read from the event row of an event organized by the invoker, which the `event_all` policy makes visible.
DROP POLICY guest_insert ON vibetype.guest;
CREATE POLICY guest_insert ON vibetype.guest FOR INSERT
WITH CHECK (
  guest.event_id = ANY ((SELECT vibetype_private.events_organized())::UUID[])
  AND
  COALESCE(
    vibetype.event_guest_count_maximum(guest.event_id) > (SELECT e.guest_count FROM vibetype.event e WHERE e.id = guest.event_id),
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

COMMIT;
