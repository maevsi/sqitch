-- Deploy maevsi:type_jwt to pg
-- requires: schema_public

BEGIN;

CREATE TYPE maevsi.jwt AS (
  id UUID,
  account_id UUID,
  account_username TEXT,
  "exp" BIGINT,
  invitations UUID[],
  role TEXT
);

COMMIT;
