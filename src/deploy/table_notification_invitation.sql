BEGIN;

CREATE TABLE vibetype.notification_invitation (
  guest_id            UUID NOT NULL REFERENCES vibetype.guest(id)
)
INHERITS (vibetype.notification);

COMMENT ON TABLE vibetype.notification_invitation IS '@omit update,delete\nStores invitations and their statuses.';
COMMENT ON COLUMN vibetype.notification_invitation.guest_id IS 'The ID of the guest associated with this invitation.';

CREATE INDEX idx_invitation_guest_id ON vibetype.notification_invitation USING btree (guest_id);

COMMIT;
