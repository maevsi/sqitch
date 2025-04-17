BEGIN;

CREATE TABLE vibetype.account_preference_event_size (
  account_id  UUID REFERENCES vibetype.account(id) ON DELETE CASCADE,
  event_size  vibetype.event_size,

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (account_id, event_size)
);

COMMENT ON TABLE vibetype.account_preference_event_size IS 'Table for the user accounts'' preferred event sizes (M:N relationship).';
COMMENT ON COLUMN vibetype.account_preference_event_size.account_id IS 'The account''s internal id.';
COMMENT ON COLUMN vibetype.account_preference_event_size.event_size IS 'A preferred event sized';
COMMENT ON COLUMN vibetype.account_preference_event_size.created_at IS E'@omit create,update\nTimestamp of when the event size preference was created, defaults to the current timestamp.';

GRANT SELECT, INSERT, DELETE ON TABLE vibetype.account_preference_event_size TO vibetype_account;

ALTER TABLE vibetype.account_preference_event_size ENABLE ROW LEVEL SECURITY;

CREATE POLICY account_preference_event_size_all ON vibetype.account_preference_event_size FOR ALL
USING (
  account_id = vibetype.invoker_account_id()
);

END;
