BEGIN;

CREATE TYPE maevsi.event_visibility AS ENUM (
  'public',
  'private',
  'unlisted'
);

COMMENT ON TYPE maevsi.event_visibility IS 'Possible visibilities of events and event groups: public, private, unlisted.';

COMMIT;
