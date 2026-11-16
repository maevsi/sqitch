BEGIN;

DROP FUNCTION vibetype.event_attendees(vibetype.event);
DROP FUNCTION vibetype_private.event_attendee_account_ids(UUID);

COMMIT;
