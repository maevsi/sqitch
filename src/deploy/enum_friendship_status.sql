BEGIN;

CREATE TYPE maevsi.friendship_status AS ENUM (
  'accepted',
  'pending',
  'rejected'
);

COMMENT ON TYPE maevsi.friendship_status IS 'Possible status values of a friend relation.';

COMMIT;
