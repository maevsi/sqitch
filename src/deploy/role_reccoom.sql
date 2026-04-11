BEGIN;

\set role_service_reccoom_password `cat /run/secrets/postgres_role_service_reccoom_password`
\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

DROP ROLE IF EXISTS :role_service_reccoom_username;
CREATE ROLE :role_service_reccoom_username LOGIN PASSWORD :'role_service_reccoom_password';

GRANT SELECT ON TABLE vibetype.event TO :role_service_reccoom_username; -- TODO: move this to table event policy in next major release

COMMIT;
