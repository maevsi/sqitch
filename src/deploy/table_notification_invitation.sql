BEGIN;

CREATE TABLE vibetype.notification_invitation (
  guest_id            UUID NOT NULL REFERENCES vibetype.guest(id)
)
INHERITS (vibetype.notification);

CREATE INDEX idx_invitation_guest_id ON vibetype.notification_invitation USING btree (guest_id);

COMMENT ON TABLE vibetype.notification_invitation IS '@omit update,delete\nStores invitations and their statuses.';
COMMENT ON COLUMN vibetype.notification_invitation.guest_id IS 'The ID of the guest associated with this invitation.';

GRANT SELECT ON vibetype.notification_invitation TO vibetype_account;

ALTER TABLE vibetype.notification_invitation ENABLE ROW LEVEL SECURITY;

COMMIT;
