BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`
SET local role.vibetype_username TO :'role_service_vibetype_username';

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype_private.outbox_guest_invitation_resolve(UUID)', 'EXECUTE'));
  ASSERT NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype_private.outbox_guest_invitation_resolve(UUID)', 'EXECUTE'));
  ASSERT (SELECT pg_catalog.has_function_privilege(current_setting('role.vibetype_username'), 'vibetype_private.outbox_guest_invitation_resolve(UUID)', 'EXECUTE'));
END $$;

ROLLBACK;
