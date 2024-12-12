BEGIN;

CREATE TYPE maevsi.invitation_feedback AS ENUM (
  'accepted',
  'canceled'
);

COMMENT ON TYPE maevsi.invitation_feedback IS 'Possible answers to an invitation: accepted, canceled.';

COMMIT;
