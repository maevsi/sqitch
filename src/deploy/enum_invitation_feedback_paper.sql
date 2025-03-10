BEGIN;

CREATE TYPE vibetype.invitation_feedback_paper AS ENUM (
  'none',
  'paper',
  'digital'
);

COMMENT ON TYPE vibetype.invitation_feedback_paper IS 'Possible choices on how to receive a paper invitation: none, paper, digital.';

COMMIT;
