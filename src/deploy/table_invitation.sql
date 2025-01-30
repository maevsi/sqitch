BEGIN;

CREATE TABLE maevsi.invitation(
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  guest_id    UUID NOT NULL REFERENCES maevsi.guest(id),
  action      maevsi.invitation_action NOT NULL,
  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE(guest_id, created_at , action)
);

COMMENT ON TABLE maevsi.invitation IS '@omit update,delete\nThe table tracks actions around invitations.';
COMMENT ON COLUMN maevsi.invitation.id IS E'@omit create\nThe tracking record''s internal id.';
COMMENT ON COLUMN maevsi.invitation.action IS 'The action';
COMMENT ON COLUMN maevsi.invitation.guest_id IS 'The guest information (containing event and contact).';
COMMENT ON COLUMN maevsi.invitation.created_at IS '@omit create\nThe timestamp when the action was executed';

COMMIT;
