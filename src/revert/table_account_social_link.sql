-- Revert maevsi:table_account_social_link from pg

BEGIN;

DROP TABLE maevsi.account_social_link ;

COMMIT;
