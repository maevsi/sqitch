BEGIN;

\set role_service_grafana_username `cat /run/secrets/postgres-role-service-grafana-username`

-- The dashboard only needs metadata columns for its statistics.
REVOKE SELECT ON TABLE vibetype_private.account FROM :role_service_grafana_username;
GRANT SELECT (
  id,
  birth_date,
  email_address,
  email_address_verification_valid_until,
  location,
  password_reset_verification_valid_until,
  upload_quota_bytes,
  created_at,
  last_activity
) ON TABLE vibetype_private.account TO :role_service_grafana_username;

REVOKE SELECT ON TABLE vibetype_private.notification FROM :role_service_grafana_username;
GRANT SELECT (
  id,
  channel,
  is_acknowledged,
  created_at
) ON TABLE vibetype_private.notification TO :role_service_grafana_username;

COMMIT;
