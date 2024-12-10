-- Deploy maevsi:table_event_category_policy to pg
-- requires: schema_public
-- requires: table_event_category
-- requires: role_anonymous
-- requires: role_account

BEGIN;

GRANT SELECT ON TABLE maevsi.event_category TO maevsi_anonymous, maevsi_account;

-- no row level security necessary for this table as it does not contain user data

COMMIT;
