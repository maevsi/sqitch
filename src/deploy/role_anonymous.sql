BEGIN;

DROP ROLE IF EXISTS maevsi_anonymous;
CREATE ROLE maevsi_anonymous;

GRANT maevsi_anonymous to maevsi_postgraphile;

COMMIT;
