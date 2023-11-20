BEGIN;

\set role_maevsi_tusd_username `cat /run/secrets/postgres_role_maevsi-tusd_username`

CREATE SCHEMA maevsi;

COMMENT ON SCHEMA maevsi IS 'Is used by PostGraphile.';

GRANT USAGE ON SCHEMA maevsi TO maevsi_anonymous, maevsi_account, :role_maevsi_tusd_username;

COMMIT;
