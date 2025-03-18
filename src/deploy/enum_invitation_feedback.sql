BEGIN;

CREATE TYPE vibetype.invitation_feedback AS ENUM (
  'accepted',
  'canceled'
);

COMMENT ON TYPE vibetype.invitation_feedback IS 'Possible answers to an invitation: accepted, canceled.';

COMMIT;
