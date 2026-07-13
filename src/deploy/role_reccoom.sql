BEGIN;

\set role_service_reccoom_password `cat /run/secrets/postgres-role-service-reccoom-password`
\set role_service_reccoom_username `cat /run/secrets/postgres-role-service-reccoom-username`

DROP ROLE IF EXISTS :role_service_reccoom_username;
CREATE ROLE :role_service_reccoom_username LOGIN PASSWORD :'role_service_reccoom_password' BYPASSRLS;

COMMIT;
