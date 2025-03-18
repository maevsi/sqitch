BEGIN;

CREATE TABLE vibetype.guest (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  contact_id        UUID NOT NULL REFERENCES vibetype.contact(id),
  event_id          UUID NOT NULL REFERENCES vibetype.event(id),
  feedback          vibetype.invitation_feedback,
  feedback_paper    vibetype.invitation_feedback_paper,

  created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP WITH TIME ZONE,
  updated_by        UUID REFERENCES vibetype.account(id),

  UNIQUE (event_id, contact_id)
);

COMMENT ON TABLE vibetype.guest IS 'A guest for a contact. A bidirectional mapping between an event and a contact.';
COMMENT ON COLUMN vibetype.guest.id IS E'@omit create,update\nThe guests''s internal id.';
COMMENT ON COLUMN vibetype.guest.contact_id IS 'The internal id of the guest''s contact.';
COMMENT ON COLUMN vibetype.guest.event_id IS 'The internal id of the guest''s event.';
COMMENT ON COLUMN vibetype.guest.feedback IS 'The guest''s general feedback status.';
COMMENT ON COLUMN vibetype.guest.feedback_paper IS 'The guest''s paper feedback status.';
COMMENT ON COLUMN vibetype.guest.created_at IS E'@omit create,update\nTimestamp of when the guest was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.guest.updated_at IS E'@omit create,update\nTimestamp of when the guest was last updated.';
COMMENT ON COLUMN vibetype.guest.updated_by IS E'@omit create,update\nThe id of the account which last updated the guest. `NULL` if the guest was updated by an anonymous user.';

-- GRANTs, RLS and POLICYs are specified in 'table_guest_policy`.

COMMIT;
