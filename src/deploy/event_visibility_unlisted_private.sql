BEGIN;

UPDATE vibetype.event SET visibility = 'private' WHERE visibility = 'unlisted';

COMMIT;
