BEGIN;

DROP POLICY guest_insert_join ON vibetype.guest;

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

  RETURN NULL;
END;
$$;

COMMIT;
