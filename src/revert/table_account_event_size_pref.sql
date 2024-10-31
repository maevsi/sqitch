-- Revert maevsi:table_maevsi.account_event_size_pref from pg

BEGIN;

DROP TABLE maevsi.account_event_size_pref;

COMMIT;
