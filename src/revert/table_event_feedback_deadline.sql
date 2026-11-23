BEGIN;

COMMENT ON FUNCTION vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT) IS E'@turnstileProtected\nJoins the event of a general invitation link as a guest who accepted, and returns the guest''s id. An account joins with its own contact and gets its existing guest back if it already joined. Without an account, the email address and first name become a new contact of the organizer.\n\nError codes:\n- **VTILN** when the invitation link does not exist.\n- **VTEEN** when the event has ended.\n- **VTIDM** when an email address or first name is missing without an account.\n- **VTGCM** when the event''s maximum guest count is reached.';

DROP TRIGGER feedback_deadline_update ON vibetype.guest;
DROP TRIGGER feedback_deadline_insert ON vibetype.guest;
DROP FUNCTION vibetype_private.trigger_guest_feedback_deadline();

ALTER TABLE vibetype.event DROP COLUMN feedback_deadline;

COMMIT;
