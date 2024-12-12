-- Revert maevsi:table_event_upload from pg

BEGIN;

DROP TABLE maevsi.event_upload;

COMMIT;
