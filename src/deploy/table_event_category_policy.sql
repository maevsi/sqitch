BEGIN;

GRANT SELECT ON TABLE vibetype.event_category TO vibetype_anonymous, vibetype_account;

-- no row level security necessary for this table as it does not contain user data

COMMIT;
