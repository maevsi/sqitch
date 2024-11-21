-- Revert maevsi:table_social_network from pg

BEGIN;

DROP TABLE maevsi.social_network;

COMMIT;
