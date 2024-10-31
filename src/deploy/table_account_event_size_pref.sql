-- Deploy maevsi:table_account_private to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: enum_event_size

BEGIN;

CREATE TABLE maevsi.account_event_size_pref (
  account_id  UUID REFERENCES maevsi.account(id),
  event_size  maevsi.event_size,

  PRIMARY KEY (account_id, event_size)
);

COMMENT ON TABLE maevsi.account_event_size_pref IS 'Table for the user accounts'' preferred event sizes (M:N relationship).';
COMMENT ON COLUMN maevsi.account_event_size_pref.account_id IS 'The account''s internal id.';
COMMENT ON COLUMN maevsi.account_event_size_pref.event_size IS 'A preferred event sized';

END;
