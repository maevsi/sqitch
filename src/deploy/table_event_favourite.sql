BEGIN;

CREATE TABLE maevsi.event_favourite (
  account_id uuid NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE,
  event_id uuid NOT NULL REFERENCES maevsi.event(id) ON DELETE CASCADE,

  PRIMARY KEY (account_id, event_id)
);

COMMENT ON TABLE maevsi.event_favourite IS 'The user accounts'' favourite events.';
COMMENT ON COLUMN maevsi.event_favourite.account_id IS 'A user account id.';
COMMENT ON COLUMN maevsi.event_favourite.event_id IS 'The ID of an event which the user marked as a favourite.';

COMMIT;
