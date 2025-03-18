BEGIN;

\set role_vibetype_tusd_password `cat /run/secrets/postgres_role_vibetype-tusd_password`

DROP ROLE IF EXISTS vibetype_tusd;
CREATE ROLE vibetype_tusd LOGIN PASSWORD :'role_vibetype_tusd_password';

GRANT vibetype_tusd to vibetype_postgraphile;

COMMIT;
