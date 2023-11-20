-- Revert maevsi:table_contact from pg

BEGIN;

DROP TRIGGER maevsi_trigger_contact_update_account_id ON maevsi.contact;

DROP FUNCTION maevsi.trigger_contact_update_account_id;

DROP TABLE maevsi.contact;

COMMIT;
