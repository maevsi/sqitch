BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

-- Checks the effective privileges, as a membership granted by another role could still inherit.
SELECT 1 / (
  NOT pg_has_role(:'role_service_postgraphile_username', :'role_service_vibetype_username', 'USAGE')
  AND pg_has_role(:'role_service_postgraphile_username', :'role_service_vibetype_username', 'SET')
)::INTEGER;

ROLLBACK;
