-- Deploy maevsi:type_event_unlock_response to pg
-- requires: schema_public
-- requires: type_jwt

BEGIN;

CREATE TYPE maevsi.event_unlock_response AS (
  author_account_id TEXT,
  event_slug TEXT,
  jwt maevsi.jwt
);

COMMIT;
