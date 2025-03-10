BEGIN;

\set role_vibetype_username `cat /run/secrets/postgres_role_vibetype_username`

CREATE SCHEMA vibetype;

COMMENT ON SCHEMA vibetype IS 'Is used by PostGraphile.';

GRANT USAGE ON SCHEMA vibetype TO vibetype_anonymous, vibetype_account, :role_vibetype_username;

COMMIT;
