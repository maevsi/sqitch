BEGIN;

CREATE TYPE vibetype.notification_type AS ENUM (
  'event_deleted',
  'event_invitation',
  'event_updated',
  'friendship_accepted',
  'friendship_requested',
  'guest_feedback'
);

COMMENT ON TYPE vibetype.notification_type IS 'Kinds of notifications an account receives: event_deleted, event_invitation, event_updated, friendship_accepted, friendship_requested, guest_feedback.';

COMMIT;
