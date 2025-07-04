BEGIN;

ALTER TABLE vibetype.account
  ALTER COLUMN username
  TYPE TEXT COLLATE "default";

COMMIT;
