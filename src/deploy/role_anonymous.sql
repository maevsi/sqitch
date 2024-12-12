BEGIN;

CREATE ROLE maevsi_anonymous;

GRANT maevsi_anonymous to maevsi_postgraphile;

COMMIT;
