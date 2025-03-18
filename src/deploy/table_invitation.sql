BEGIN;

CREATE TABLE vibetype.invitation (
  guest_id            UUID NOT NULL REFERENCES vibetype.guest(id),
  -- created_at is already  column of table notification
  created_by          UUID NOT NULL REFERENCES vibetype.account(id)
)
INHERITS (vibetype.notification);

COMMENT ON TABLE vibetype.invitation IS '@omit update,delete\nStores invitations and their statuses.';
COMMENT ON COLUMN vibetype.invitation.guest_id IS 'The ID of the guest associated with this invitation.';
COMMENT ON COLUMN vibetype.invitation.created_by IS E'@omit create\nReference to the account that created the invitation.';

COMMIT;
