BEGIN;

ALTER TABLE vibetype.event
  DROP COLUMN effective_end;

COMMIT;
