-- Revert maevsi:table_account_interest_policy from pg

BEGIN;

DROP POLICY account_interest_select ON maevsi.account_interest;
DROP POLICY account_interest_insert ON maevsi.account_interest;
DROP POLICY account_interest_delete ON maevsi.account_interest;

COMMIT;
