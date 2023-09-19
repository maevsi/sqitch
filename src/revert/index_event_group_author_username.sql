-- Revert maevsi:index_event_group_author_account_id from pg

BEGIN;

DROP INDEX maevsi.idx_event_group_author_account_id;

COMMIT;
