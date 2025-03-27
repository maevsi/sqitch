BEGIN;

CREATE TABLE vibetype.account_preference_event_category (
    account_id UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
    category_id UUID NOT NULL REFERENCES vibetype.event_category(id) ON DELETE CASCADE,

    PRIMARY KEY (account_id, category_id)
);

COMMENT ON TABLE vibetype.account_preference_event_category IS 'Event categories a user account is interested in (M:N relationship).';
COMMENT ON COLUMN vibetype.account_preference_event_category.account_id IS 'A user account id.';
COMMENT ON COLUMN vibetype.account_preference_event_category.category_id IS 'An event category id.';

COMMIT;
