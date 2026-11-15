BEGIN;

DO $$
BEGIN
  ASSERT (SELECT count(*) = 6 FROM pg_catalog.pg_trigger WHERE tgname LIKE 'notification\_%' AND NOT tgisinternal);
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_event_deleted()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_event_invitation()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_event_updated()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_friendship_accepted()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_friendship_requested()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.trigger_account_notification_guest_feedback()', 'EXECUTE'));
END $$;

ROLLBACK;
