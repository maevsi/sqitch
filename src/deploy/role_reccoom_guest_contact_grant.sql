BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

GRANT SELECT ON TABLE vibetype.guest TO :role_service_reccoom_username;
GRANT SELECT ON TABLE vibetype.contact TO :role_service_reccoom_username;

COMMIT;
