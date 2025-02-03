BEGIN;

CREATE TYPE maevsi.invitation_status AS ENUM (
  'accepted',
  'bounced',
  'rejected',
  'sent'
);

COMMENT ON TYPE maevsi.invitation_status IS 'Represents the status of an invitation.';

COMMIT;
