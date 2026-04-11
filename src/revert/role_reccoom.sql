BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

REVOKE ALL PRIVILEGES ON TABLE vibetype.event FROM :role_service_reccoom_username; -- TODO: remove this line in the next major release.
DROP ROLE :role_service_reccoom_username;

COMMIT;
