BEGIN;

-- TODO: remove type
CREATE TYPE maevsi.event_unlock_response AS (
  creator_username TEXT,
  event_slug TEXT,
  jwt maevsi.jwt
);

COMMIT;
