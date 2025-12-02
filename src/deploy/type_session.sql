BEGIN;

CREATE TYPE vibetype.jwt AS (
  id UUID,
  account_id UUID,
  account_username TEXT,
  "exp" BIGINT,
  guests UUID[],
  role TEXT
);

COMMIT;
