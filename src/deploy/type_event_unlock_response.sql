BEGIN;

-- TODO: remove type
CREATE TYPE vibetype.event_unlock_response AS (
  creator_username TEXT,
  event_slug TEXT,
  session vibetype.session
);

COMMIT;
