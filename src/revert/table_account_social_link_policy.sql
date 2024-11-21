-- Revert maevsi:table_account_social_link_policy from pg

BEGIN;

DROP POLICY account_social_link_select ON maevsi.account_social_link;
DROP POLICY account_social_link_insert ON maevsi.account_social_link;
DROP POLICY account_social_link_delete ON maevsi.account_social_link;

COMMIT;
