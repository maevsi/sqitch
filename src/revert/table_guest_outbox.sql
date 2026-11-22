BEGIN;

DROP FUNCTION vibetype_private.outbox_guest_acceptance_resolve(UUID);

DROP TRIGGER outbox_accepted ON vibetype.guest;
DROP FUNCTION vibetype.trigger_guest_outbox();

COMMIT;
