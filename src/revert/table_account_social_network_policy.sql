-- Revert maevsi:table_account_social_network_policy from pg

BEGIN;

DROP POLICY account_social_network_insert ON maevsi.account_social_network;
DROP POLICY account_social_network_update ON maevsi.account_social_network;
DROP POLICY account_social_network_delete ON maevsi.account_social_network;

COMMIT;
