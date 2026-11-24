BEGIN;

ALTER TABLE vibetype.event ADD COLUMN feedback_deadline TIMESTAMP WITH TIME ZONE;

COMMENT ON COLUMN vibetype.event.feedback_deadline IS 'The point in time from which on only the organizer can change the feedback of the event''s guests. No deadline when `NULL`.';

GRANT INSERT (feedback_deadline), UPDATE (feedback_deadline) ON TABLE vibetype.event TO vibetype_account;

-- Security definer because guests without an account may be unable to select their event.
CREATE FUNCTION vibetype_private.trigger_guest_feedback_deadline() RETURNS TRIGGER
    LANGUAGE plpgsql SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = NEW.event_id
      AND e.feedback_deadline <= CURRENT_TIMESTAMP
      AND e.created_by IS DISTINCT FROM vibetype.invoker_account_id()
  ) THEN
    RAISE 'The event''s feedback deadline has passed.' USING ERRCODE = 'VTFDP';
  END IF;

  RETURN NEW;
END;
$$;
COMMENT ON FUNCTION vibetype_private.trigger_guest_feedback_deadline() IS 'Rejects feedback from anyone but the organizer once the event''s feedback deadline has passed.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_guest_feedback_deadline() FROM PUBLIC;

-- Inserts carry feedback when a guest joins an event or redeems an invitation link.
CREATE TRIGGER feedback_deadline_insert
  BEFORE INSERT
  ON vibetype.guest
  FOR EACH ROW
  WHEN (NEW.feedback IS NOT NULL OR NEW.feedback_paper IS NOT NULL)
  EXECUTE FUNCTION vibetype_private.trigger_guest_feedback_deadline();

CREATE TRIGGER feedback_deadline_update
  BEFORE UPDATE OF feedback, feedback_paper
  ON vibetype.guest
  FOR EACH ROW
  WHEN (NEW.feedback IS DISTINCT FROM OLD.feedback OR NEW.feedback_paper IS DISTINCT FROM OLD.feedback_paper)
  EXECUTE FUNCTION vibetype_private.trigger_guest_feedback_deadline();

COMMENT ON FUNCTION vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT) IS E'@turnstileProtected\nJoins the event of a general invitation link as a guest who accepted, and returns the guest''s id. An account joins with its own contact and gets its existing guest back if it already joined. Without an account, the email address and first name become a new contact of the organizer.\n\nError codes:\n- **VTILN** when the invitation link does not exist.\n- **VTEEN** when the event has ended.\n- **VTFDP** when the event''s feedback deadline has passed.\n- **VTIDM** when an email address or first name is missing without an account.\n- **VTGCM** when the event''s maximum guest count is reached.';

COMMIT;
