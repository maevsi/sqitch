-- Verify maevsi:table_social_network on pg

BEGIN;

SELECT "name"
FROM maevsi.social_network WHERE FALSE;

ROLLBACK;
