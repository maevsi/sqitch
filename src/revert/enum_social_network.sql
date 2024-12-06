-- Revert maevsi:enum_social_network from pg

BEGIN;

DROP TYPE maevsi.social_network;

COMMIT;
