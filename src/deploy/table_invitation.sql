BEGIN;

CREATE TABLE maevsi.invitation (
  guest_id            UUID NOT NULL REFERENCES maevsi.guest(id),
  -- created_at is already  column of table notification
  created_by          UUID NOT NULL REFERENCES maevsi.account(id)
)
INHERITS (maevsi.notification);

COMMENT ON TABLE maevsi.invitation IS '@omit update,delete\nStores invitations and their statuses.';
COMMENT ON COLUMN maevsi.invitation.guest_id IS 'The ID of the guest associated with this invitation.';
COMMENT ON COLUMN maevsi.invitation.created_by IS E'@omit create\nReference to the account that created the invitation.';

COMMIT;
