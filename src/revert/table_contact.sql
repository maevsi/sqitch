BEGIN;

DROP TRIGGER vibetype_trigger_contact_update_account_id ON vibetype.contact;

DROP FUNCTION vibetype.trigger_contact_update_account_id();

DROP TABLE vibetype.contact;

COMMIT;
