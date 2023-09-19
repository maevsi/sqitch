-- Deploy maevsi:index_event_author_account_id to pg
-- requires: table_event

BEGIN;

CREATE INDEX idx_event_author_account_id ON maevsi.event (author_account_id);

COMMENT ON INDEX maevsi.idx_event_author_account_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
