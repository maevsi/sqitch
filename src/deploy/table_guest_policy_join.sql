BEGIN;

-- Permissive policies combine with `OR`, so this adds to the organizer's `guest_insert` without touching it.
-- The event lookup runs under `event_select`, which hides public events whose organizer is involved in a block with the invoker.
-- The own contact is the one an account created for itself on registration.
CREATE POLICY guest_insert_join ON vibetype.guest FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = guest.event_id
      AND e.published_at <= CURRENT_TIMESTAMP
      AND e.visibility = 'public'
      AND (e.guest_count_maximum IS NULL OR e.guest_count_maximum > e.guest_count)
  )
  AND EXISTS (
    SELECT 1
    FROM vibetype.contact c
    WHERE c.id = guest.contact_id
      AND c.account_id = (SELECT vibetype.invoker_account_id())
      AND c.created_by = (SELECT vibetype.invoker_account_id())
  )
);

-- The insert policies compare against the guest count as it was before the statement, so concurrent joins or one statement inserting several guests could exceed the maximum.
-- The counter is updated under a row lock, so checking it afterwards sees every committed guest.
CREATE OR REPLACE FUNCTION vibetype_private.trigger_guest_count_insert() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM 1
  FROM vibetype.event
  WHERE id IN (SELECT event_id FROM guest_inserted)
  ORDER BY id
  FOR UPDATE;

  UPDATE vibetype.event
  SET guest_count = event.guest_count + g.guest_count,
      guest_count_accepted = event.guest_count_accepted + g.guest_count_accepted
  FROM (
    SELECT event_id,
           SUM(1 + companion_count)::INTEGER AS guest_count,
           (COALESCE(SUM(1 + companion_count) FILTER (WHERE COALESCE(feedback_override, feedback) = 'accepted'), 0))::INTEGER AS guest_count_accepted
    FROM guest_inserted
    GROUP BY event_id
  ) g
  WHERE event.id = g.event_id;

  IF EXISTS (
    SELECT 1
    FROM vibetype.event
    WHERE id IN (SELECT event_id FROM guest_inserted)
      AND guest_count > guest_count_maximum
  ) THEN
    RAISE 'The event''s maximum guest count is reached.' USING ERRCODE = 'VTGCM';
  END IF;

  RETURN NULL;
END;
$$;

COMMIT;
