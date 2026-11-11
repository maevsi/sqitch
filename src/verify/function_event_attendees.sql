BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_attendees(vibetype.event)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_attendees(vibetype.event)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.event_attendee_account_ids(UUID)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.event_attendee_account_ids(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
