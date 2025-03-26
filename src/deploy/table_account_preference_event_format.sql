BEGIN;

CREATE TABLE vibetype.account_preference_event_format (
    account_id UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
    format_id UUID NOT NULL REFERENCES vibetype.event_format(id) ON DELETE CASCADE,
    created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (account_id, format_id)
);

COMMENT ON TABLE vibetype.account_preference_event_format IS 'Event formats a user account is interested in (M:N relationship).';
COMMENT ON COLUMN vibetype.account_preference_event_format.account_id IS 'A user account id.';
COMMENT ON COLUMN vibetype.account_preference_event_format.format_id IS 'The id of an event format.';
COMMENT ON COLUMN vibetype.account_preference_event_format.created_at IS 'The timestammp when the record was created..';

COMMIT;
