BEGIN;

CREATE SCHEMA vibetype;

COMMENT ON SCHEMA vibetype IS 'Is used by PostGraphile.';

GRANT USAGE ON SCHEMA vibetype TO vibetype_anonymous, vibetype_account, vibetype_tusd;

COMMIT;
