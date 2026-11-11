BEGIN;

DROP TRIGGER outbox_accepted ON vibetype.friendship;
DROP TRIGGER outbox_requested ON vibetype.friendship;
DROP FUNCTION vibetype.trigger_friendship_outbox();

COMMIT;
