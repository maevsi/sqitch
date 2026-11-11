BEGIN;

\set role_service_gizmosql_username `cat /run/secrets/postgres-role-service-gizmosql-username`

DROP ROLE :role_service_gizmosql_username;

COMMIT;
