BEGIN;

DROP POLICY account_social_network_all ON vibetype.account_social_network;
DROP POLICY account_social_network_select ON vibetype.account_social_network;

DROP TABLE vibetype.account_social_network;

COMMIT;
