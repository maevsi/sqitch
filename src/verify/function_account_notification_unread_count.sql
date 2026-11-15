BEGIN;

DO $$
BEGIN
  ASSERT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.account_notification_unread_count()', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.account_notification_unread_count()', 'EXECUTE'));
END $$;

ROLLBACK;
