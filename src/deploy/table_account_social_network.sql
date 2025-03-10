BEGIN;

CREATE TABLE vibetype.account_social_network (
    account_id              UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
    social_network          vibetype.social_network NOT NULL,
    social_network_username TEXT NOT NULL,

    PRIMARY KEY (account_id, social_network)
);

COMMENT ON TABLE vibetype.account_social_network IS 'Links accounts to their social media profiles. Each entry represents a specific social network and associated username for an account.';
COMMENT ON COLUMN vibetype.account_social_network.account_id IS 'The unique identifier of the account.';
COMMENT ON COLUMN vibetype.account_social_network.social_network IS 'The social network to which the account is linked.';
COMMENT ON COLUMN vibetype.account_social_network.social_network_username IS 'The username of the account on the specified social network.';
COMMENT ON CONSTRAINT account_social_network_pkey ON vibetype.account_social_network IS 'Ensures uniqueness by combining the account ID and social network, allowing each account to have a single entry per social network.';

COMMIT;
