BEGIN;

DROP POLICY account_interest_delete ON vibetype.account_interest;
DROP POLICY account_interest_insert ON vibetype.account_interest;
DROP POLICY account_interest_select ON vibetype.account_interest;

COMMIT;
