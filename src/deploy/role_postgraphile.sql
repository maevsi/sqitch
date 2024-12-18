BEGIN;

\set role_maevsi_postgraphile_password `cat /run/secrets/postgres_role_maevsi-postgraphile_password`

DROP ROLE IF EXISTS maevsi_postgraphile;
CREATE ROLE maevsi_postgraphile LOGIN PASSWORD :'role_maevsi_postgraphile_password';

COMMIT;
