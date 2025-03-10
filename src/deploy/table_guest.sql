BEGIN;

CREATE TABLE maevsi.guest (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  contact_id        UUID NOT NULL REFERENCES maevsi.contact(id),
  event_id          UUID NOT NULL REFERENCES maevsi.event(id),
  feedback          maevsi.invitation_feedback,
  feedback_paper    maevsi.invitation_feedback_paper,

  created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at        TIMESTAMP WITH TIME ZONE,
  updated_by        UUID REFERENCES maevsi.account(id),

  UNIQUE (event_id, contact_id)
);

CREATE INDEX idx_guest_updated_by ON maevsi.guest USING btree (updated_by);

COMMENT ON TABLE maevsi.guest IS 'A guest for a contact. A bidirectional mapping between an event and a contact.';
COMMENT ON COLUMN maevsi.guest.id IS E'@omit create,update\nThe guests''s internal id.';
COMMENT ON COLUMN maevsi.guest.contact_id IS 'The internal id of the guest''s contact.';
COMMENT ON COLUMN maevsi.guest.event_id IS 'The internal id of the guest''s event.';
COMMENT ON COLUMN maevsi.guest.feedback IS 'The guest''s general feedback status.';
COMMENT ON COLUMN maevsi.guest.feedback_paper IS 'The guest''s paper feedback status.';
COMMENT ON COLUMN maevsi.guest.created_at IS E'@omit create,update\nTimestamp of when the guest was created, defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.guest.updated_at IS E'@omit create,update\nTimestamp of when the guest was last updated.';
COMMENT ON COLUMN maevsi.guest.updated_by IS E'@omit create,update\nThe id of the account which last updated the guest. `NULL` if the guest was updated by an anonymous user.';
COMMENT ON INDEX maevsi.idx_guest_updated_by IS 'B-Tree index to optimize lookups by updater.';

-- GRANTs, RLS and POLICYs are specified in `table_guest_policy`.

COMMIT;
