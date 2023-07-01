-- Revert maevsi:index_event_author_account_id from pg

BEGIN;

DROP INDEX maevsi.idx_event_author_account_id;

COMMIT;
