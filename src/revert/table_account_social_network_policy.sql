BEGIN;

DROP POLICY account_social_network_delete ON vibetype.account_social_network;
DROP POLICY account_social_network_update ON vibetype.account_social_network;
DROP POLICY account_social_network_insert ON vibetype.account_social_network;

COMMIT;
