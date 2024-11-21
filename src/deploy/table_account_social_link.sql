-- Deploy maevsi:table_event_category_mapping to pg
-- requires: schema_public
-- requires: table_account
-- requires: table_social_network

BEGIN;

CREATE TABLE maevsi.account_social_link (
    account_id              UUID NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
    social_network_name     TEXT NOT NULL REFERENCES maevsi.social_network(name) ON DELETE CASCADE,
    social_network_username TEXT NOT NULL,
    PRIMARY KEY (account_id, social_network_name)
);

COMMENT ON TABLE maevsi.account_social_link IS 'Collects the account''s user names in social networks.';
COMMENT ON COLUMN maevsi.account_social_link.account_id IS 'The account ID.';
COMMENT ON COLUMN maevsi.account_social_link.social_network_name IS 'The social network name.';
COMMENT ON COLUMN maevsi.account_social_link.social_network_username IS 'The account owner''s user name in the social network.';

COMMIT;
