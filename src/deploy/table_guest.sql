BEGIN;

CREATE TABLE vibetype.guest (
  id                        UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  contact_id                UUID NOT NULL REFERENCES vibetype.contact(id) ON DELETE CASCADE,
  event_id                  UUID NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,
  feedback                  vibetype.invitation_feedback,
  feedback_override         vibetype.invitation_feedback,
  feedback_reason           TEXT CHECK (char_length(feedback_reason) > 0 AND char_length(feedback_reason) <= 1000),
  companion_count           INTEGER NOT NULL DEFAULT 0 CHECK (companion_count >= 0),
  companion_count_requested INTEGER CHECK (companion_count_requested > 0),

  created_at                TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at                TIMESTAMP WITH TIME ZONE,
  updated_by                UUID REFERENCES vibetype.account(id) ON DELETE SET NULL,

  UNIQUE (event_id, contact_id)
);

CREATE INDEX idx_guest_contact_id ON vibetype.guest USING btree (contact_id);
CREATE INDEX idx_guest_updated_by ON vibetype.guest USING btree (updated_by);

COMMENT ON TABLE vibetype.guest IS 'A guest for a contact. A bidirectional mapping between an event and a contact.';
COMMENT ON COLUMN vibetype.guest.id IS E'@behavior -insert -update\nThe guest''s internal id.';
COMMENT ON COLUMN vibetype.guest.contact_id IS 'The internal id of the guest''s contact.';
COMMENT ON COLUMN vibetype.guest.event_id IS 'The internal id of the guest''s event.';
COMMENT ON COLUMN vibetype.guest.feedback IS 'The guest''s own feedback status. Only the guest can set it.';
COMMENT ON COLUMN vibetype.guest.feedback_override IS 'The organizer''s correction of the guest''s feedback, which takes precedence over it. Only the event''s organizer can set it, so the guest''s own feedback stays as given.';
COMMENT ON COLUMN vibetype.guest.feedback_reason IS 'The guest''s optional reason for their feedback, e.g. why they declined. Only the guest can set it.';
COMMENT ON COLUMN vibetype.guest.companion_count IS E'The number of additional guests the organizer approved for the guest, each of whom takes a seat of the event. The organizer can raise it up to the request, the guest can only lower it. Setting it fails with error code **VTGCM** when the event''s maximum guest count would be exceeded. Resets to 0 when the guest''s effective feedback is `canceled`.';
COMMENT ON COLUMN vibetype.guest.companion_count_requested IS 'The number of additional guests the guest asks the organizer to approve in total. `NULL` when there is no pending request, which also holds for a request that does not exceed the approved companion count. The organizer clears it by approving or rejecting. Resets to `NULL` when the guest''s effective feedback is `canceled`.';
COMMENT ON COLUMN vibetype.guest.created_at IS E'@behavior -insert -update\nTimestamp of when the guest was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.guest.updated_at IS E'@behavior -insert -update\nTimestamp of when the guest was last updated.';
COMMENT ON COLUMN vibetype.guest.updated_by IS E'@behavior -insert -update\nThe id of the account which last updated the guest. `NULL` if the guest was updated by an anonymous user.';
COMMENT ON INDEX vibetype.idx_guest_updated_by IS 'B-Tree index to optimize lookups by updater.';

-- GRANTs, RLS and POLICYs are specified in `table_guest_policy`.

COMMIT;
