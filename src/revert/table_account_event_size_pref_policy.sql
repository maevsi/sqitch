-- Revert maevsi:table_maevsi.account_event_size_pref_policy from pg

BEGIN;

DROP POLICY account_event_size_pref_select ON maevsi.account_event_size_pref;
DROP POLICY account_event_size_pref_insert ON maevsi.account_event_size_pref;
DROP POLICY account_event_size_pref_delete ON maevsi.account_event_size_pref;

COMMIT;
