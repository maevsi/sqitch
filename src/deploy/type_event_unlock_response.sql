BEGIN;

-- TODO: remove type
CREATE TYPE maevsi.event_unlock_response AS (
  author_account_username TEXT,
  event_slug TEXT,
  jwt maevsi.jwt
);

COMMIT;
