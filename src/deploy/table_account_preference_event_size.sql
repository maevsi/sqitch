BEGIN;

CREATE TABLE maevsi.account_preference_event_size (
  account_id  UUID REFERENCES maevsi.account(id),
  event_size  maevsi.event_size,

  PRIMARY KEY (account_id, event_size)
);

COMMENT ON TABLE maevsi.account_preference_event_size IS 'Table for the user accounts'' preferred event sizes (M:N relationship).';
COMMENT ON COLUMN maevsi.account_preference_event_size.account_id IS 'The account''s internal id.';
COMMENT ON COLUMN maevsi.account_preference_event_size.event_size IS 'A preferred event sized';

END;
