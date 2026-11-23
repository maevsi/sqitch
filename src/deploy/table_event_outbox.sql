BEGIN;

CREATE FUNCTION vibetype.trigger_event_outbox() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  -- The guest count is maintained by triggers on `vibetype.guest`, so an update moving only the counter is no change to the event and would make consumers reprocess it for every guest.
  IF (TG_OP = 'UPDATE' AND to_jsonb(NEW) - 'guest_count' = to_jsonb(OLD) - 'guest_count') THEN
    RETURN NULL;
  END IF;

  IF (TG_OP = 'DELETE') THEN
    PERFORM vibetype_private.outbox_insert('event', OLD.id, 'event.deleted', to_jsonb(OLD));
  ELSE
    PERFORM vibetype_private.outbox_insert('event', NEW.id, CASE TG_OP WHEN 'INSERT' THEN 'event.created' ELSE 'event.updated' END, to_jsonb(NEW));
  END IF;

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype.trigger_event_outbox() IS 'Adds an outbox event of type `event.created`, `event.updated` or `event.deleted` with a snapshot of the event.';

CREATE TRIGGER outbox
  AFTER
       INSERT
    OR UPDATE
    OR DELETE
  ON vibetype.event
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_event_outbox();

COMMIT;
