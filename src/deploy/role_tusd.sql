BEGIN;

\set role_maevsi_tusd_password `cat /run/secrets/postgres_role_maevsi_password`

DROP ROLE IF EXISTS maevsi_tusd;
CREATE ROLE maevsi_tusd LOGIN PASSWORD :'role_maevsi_tusd_password';

GRANT maevsi_tusd to maevsi_postgraphile;

COMMIT;
