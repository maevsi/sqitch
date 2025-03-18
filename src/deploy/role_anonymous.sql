BEGIN;

DROP ROLE IF EXISTS vibetype_anonymous;
CREATE ROLE vibetype_anonymous;

GRANT vibetype_anonymous to vibetype_postgraphile;

COMMIT;
