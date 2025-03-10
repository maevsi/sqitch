BEGIN;

CREATE TYPE vibetype.friendship_status AS ENUM (
  'accepted',
  'requested'
);

COMMENT ON TYPE vibetype.friendship_status IS 'Possible status values of a friend relation.
There is no status `rejected` because friendship records will be deleted when a friendship request is rejected.';

COMMIT;
