BEGIN;

SELECT id,
       channel,
       is_acknowledged,
       payload,
       created_at
FROM vibetype_private.notification WHERE FALSE;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`
SET local role.grafana_username TO :'role_service_grafana_username';

DO $$
BEGIN
  ASSERT NOT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.notification', 'payload', 'SELECT'));
  ASSERT (SELECT pg_catalog.has_column_privilege(current_setting('role.grafana_username'), 'vibetype_private.notification', 'channel', 'SELECT'));
END $$;

ROLLBACK;
