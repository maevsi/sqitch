BEGIN;

CREATE TYPE maevsi.invitation_action AS ENUM (
  'send',   -- invitation is sent by email
  'bounce'  -- invitation email bounced back
  'accept', -- invitation accepted
  'reject'  -- invitation rejected
);

COMMENT ON TYPE maevsi.invitation_action IS 'Possible actions around invitations.';

COMMIT;
