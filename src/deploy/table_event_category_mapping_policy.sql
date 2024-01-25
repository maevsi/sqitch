-- Deploy maevsi:table_event_category_mapping_policy to pg

BEGIN;

GRANT SELECT, INSERT, DELETE ON TABLE maevsi.event_category_mapping TO maevsi_account;

-- SELECT:
--      * Every event that is public, mine or that I'm invited to
-- INSERT:
--      * My events
-- DELETE:
--      * My events

COMMIT;
