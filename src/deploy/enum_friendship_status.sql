BEGIN;

CREATE TYPE maevsi.friendship_status AS ENUM (
  'accepted',
  'pending'
);

COMMENT ON TYPE maevsi.friendship_status IS 'Possible status values of a friend relation.
There is no status `rejected` because friendship records will be deleted when a friendship request is rejected.';

COMMIT;
