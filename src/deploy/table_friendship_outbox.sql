BEGIN;

CREATE FUNCTION vibetype.trigger_friendship_outbox() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM vibetype_private.outbox_insert('friendship', NEW.id, CASE TG_OP WHEN 'INSERT' THEN 'friendship.requested' ELSE 'friendship.accepted' END, to_jsonb(NEW));

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype.trigger_friendship_outbox() IS 'Adds an outbox event of type `friendship.requested` or `friendship.accepted` with a snapshot of the friendship.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_friendship_outbox() TO vibetype_account;

CREATE TRIGGER outbox_requested
  AFTER INSERT
  ON vibetype.friendship
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_friendship_outbox();

-- Withdrawing or rejecting a request and ending a friendship stay silent.
CREATE TRIGGER outbox_accepted
  AFTER UPDATE OF status
  ON vibetype.friendship
  FOR EACH ROW
  WHEN (OLD.status = 'requested'::vibetype.friendship_status AND NEW.status = 'accepted'::vibetype.friendship_status)
  EXECUTE FUNCTION vibetype.trigger_friendship_outbox();

COMMIT;
