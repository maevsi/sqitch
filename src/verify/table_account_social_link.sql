-- Verify maevsi:table_account_social_link on pg

BEGIN;

SELECT
  account_id,
  social_network_name
  social_network_username
FROM maevsi.account_social_link WHERE FALSE;

ROLLBACK;
