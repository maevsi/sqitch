BEGIN;

CREATE INDEX idx_event_group_author_account_id ON maevsi.event_group (author_account_id);

COMMENT ON INDEX maevsi.idx_event_group_author_account_id IS 'Speeds up reverse foreign key lookups.';

COMMIT;
