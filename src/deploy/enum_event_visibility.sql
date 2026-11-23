BEGIN;

CREATE TYPE vibetype.event_visibility AS ENUM (
  'public',
  'private'
);

COMMENT ON TYPE vibetype.event_visibility IS 'Possible visibilities of events and event groups: public and private.';

COMMIT;
