BEGIN;

\set role_vibetype_postgraphile_password `cat /run/secrets/postgres_role_vibetype-postgraphile_password`

DROP ROLE IF EXISTS vibetype_postgraphile;
CREATE ROLE vibetype_postgraphile LOGIN PASSWORD :'role_vibetype_postgraphile_password';

COMMIT;
