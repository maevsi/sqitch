-- Revert maevsi:table_event_recommendation from pg

BEGIN;

DROP TABLE maevsi.event_recommendation;

COMMIT;
