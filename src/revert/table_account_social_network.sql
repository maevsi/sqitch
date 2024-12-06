-- Revert maevsi:table_account_social_network from pg

BEGIN;

DROP TABLE maevsi.account_social_network ;

COMMIT;
