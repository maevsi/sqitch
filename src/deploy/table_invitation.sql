BEGIN;

CREATE TABLE maevsi.invitation(
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  guest_id    UUID NOT NULL REFERENCES maevsi.guest(id),
  status      maevsi.invitation_status NOT NULL,

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID NOT NULL REFERENCES maevsi.account(id),
  updated_at  TIMESTAMP WITH TIME ZONE,
  updated_by  UUID REFERENCES maevsi.account(id) NOT NULL,

  UNIQUE(guest_id, status, created_at)
);

COMMENT ON TABLE maevsi.invitation IS '@omit update,delete\nStores invitations and their statuses.';
COMMENT ON COLUMN maevsi.invitation.id IS E'@omit create\nThe unique identifier for the invitation.';
COMMENT ON COLUMN maevsi.invitation.guest_id IS 'The ID of the guest associated with this invitation.';
COMMENT ON COLUMN maevsi.invitation.status IS 'The current status of the invitation.';
COMMENT ON COLUMN maevsi.invitation.created_at IS E'@omit create\nTimestamp when the invitation was created. Defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.invitation.created_by IS E'@omit create\nReference to the account that created the invitation.';
COMMENT ON COLUMN maevsi.invitation.updated_at IS E'@omit create\nTimestamp when the invitation was last updated.';
COMMENT ON COLUMN maevsi.invitation.updated_by IS E'@omit create\nReference to the account that last updated the invitation.';

CREATE TRIGGER maevsi_trigger_invitation_update
  BEFORE
    UPDATE
  ON maevsi.invitation
  FOR EACH ROW
  EXECUTE PROCEDURE maevsi.trigger_metadata_update();

COMMIT;
