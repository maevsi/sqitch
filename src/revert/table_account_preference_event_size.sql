-- Revert maevsi:table_maevsi.account_preference_event_size from pg

BEGIN;

DROP TABLE maevsi.account_preference_event_size;

COMMIT;
