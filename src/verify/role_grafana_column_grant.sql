BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
SET LOCAL role.grafana_username TO :'role_service_grafana_username';

DO $$
DECLARE
  _username TEXT := current_setting('role.grafana_username');
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.account', 'password_hash', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.account', 'email_address_verification', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.account', 'password_reset_verification', 'SELECT'));
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.notification', 'payload', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.account', 'created_at', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege(_username, 'vibetype_private.notification', 'channel', 'SELECT'));
END $$;

ROLLBACK;
