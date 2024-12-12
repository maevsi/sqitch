BEGIN;

GRANT SELECT ON TABLE maevsi.event_category TO maevsi_anonymous, maevsi_account;

-- no row level security necessary for this table as it does not contain user data

COMMIT;
