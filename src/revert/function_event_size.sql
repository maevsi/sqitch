-- Revert maevsi:function_event_size from pg

BEGIN;

DROP FUNCTION maevsi.event_size;

COMMIT;
