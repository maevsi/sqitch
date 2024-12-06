-- Verify maevsi:table_account_social_network on pg

BEGIN;

SELECT
  account_id,
  social_network
  social_network_username
FROM maevsi.account_social_network WHERE FALSE;

ROLLBACK;
