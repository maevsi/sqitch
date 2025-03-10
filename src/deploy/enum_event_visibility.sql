BEGIN;

CREATE TYPE vibetype.event_visibility AS ENUM (
  'public',
  'private',
  'unlisted'
);

COMMENT ON TYPE vibetype.event_visibility IS 'Possible visibilities of events and event groups: public, private and unlisted.';

COMMIT;
