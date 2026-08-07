BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

REVOKE SELECT ON TABLE vibetype.contact FROM :role_service_reccoom_username;
REVOKE SELECT ON TABLE vibetype.guest FROM :role_service_reccoom_username;

COMMIT;
