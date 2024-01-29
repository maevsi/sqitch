-- Revert maevsi:table_user_interest_policy from pg

BEGIN;

DROP POLICY user_interest_select ON maevsi.user_interest;
DROP POLICY user_interest_insert ON maevsi.user_interest;
DROP POLICY user_interest_delete ON maevsi.user_interest;

COMMIT;
