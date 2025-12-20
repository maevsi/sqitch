BEGIN;

CREATE TYPE vibetype.jwt AS (
  attendances UUID[],
  exp BIGINT, -- expiration time as epoch
  guests UUID[],
  jti UUID, -- JWT ID
  role TEXT,
  sub UUID, -- subject (account id)
  username TEXT -- subject username
);

COMMIT;
