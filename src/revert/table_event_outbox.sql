BEGIN;

DROP TRIGGER outbox ON vibetype.event;
DROP FUNCTION vibetype.trigger_event_outbox();

COMMIT;
