-- Revert maevsi:table_maevsi.account_preference_event_size_policy from pg

BEGIN;

DROP POLICY account_preference_event_size_select ON maevsi.account_preference_event_size;
DROP POLICY account_preference_event_size_insert ON maevsi.account_preference_event_size;
DROP POLICY account_preference_event_size_delete ON maevsi.account_preference_event_size;

COMMIT;
