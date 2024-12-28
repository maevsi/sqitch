BEGIN;

CREATE TABLE maevsi.account_interest (
    account_id UUID NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
    category TEXT NOT NULL REFERENCES maevsi.event_category(category) ON DELETE CASCADE,

    PRIMARY KEY (account_id, category)
);

COMMENT ON TABLE maevsi.account_interest IS 'Event categories a user account is interested in (M:N relationship).';
COMMENT ON COLUMN maevsi.account_interest.account_id IS 'A user account id.';
COMMENT ON COLUMN maevsi.account_interest.category IS 'An event category.';

COMMIT;
