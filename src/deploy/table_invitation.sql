BEGIN;

CREATE TABLE maevsi.invitation (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  contact_id        UUID NOT NULL REFERENCES maevsi.contact(id),
  event_id          UUID NOT NULL REFERENCES maevsi.event(id),
  feedback          maevsi.invitation_feedback,
  feedback_paper    maevsi.invitation_feedback_paper,

  UNIQUE (event_id, contact_id)
);

COMMENT ON TABLE maevsi.invitation IS 'An invitation for a contact. A bidirectional mapping between an event and a contact.';
COMMENT ON COLUMN maevsi.invitation.id IS E'@omit create,update\nThe invitations''s internal id.';
COMMENT ON COLUMN maevsi.invitation.created_at IS E'@omit create,update\nTimestamp of when the invitation was created, defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.invitation.contact_id IS 'The contact''s internal id for which the invitation is valid.';
COMMENT ON COLUMN maevsi.invitation.event_id IS 'The event''s internal id for which the invitation is valid.';
COMMENT ON COLUMN maevsi.invitation.feedback IS 'The invitation''s general feedback status.';
COMMENT ON COLUMN maevsi.invitation.feedback_paper IS 'The invitation''s paper feedback status.';

-- GRANTs, RLS and POLICYs are specified in 'table_invitation_policy`.

COMMIT;
