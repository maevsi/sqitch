BEGIN;

CREATE TYPE maevsi.friend_status AS ENUM (
  'pending',
  'accepted',
  'rejected'
);

COMMENT ON TYPE maevsi.friend_status IS 'Possible status values of a friend relation.';

COMMIT;
