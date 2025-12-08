BEGIN;

DROP TRIGGER vibetype_trigger_contact_update_account_id ON vibetype.contact;
DROP FUNCTION vibetype.trigger_contact_update_account_id();

DROP TRIGGER vibetype_trigger_contact_check_time_zone ON vibetype.contact;
DROP FUNCTION vibetype.trigger_contact_check_time_zone();

DROP TABLE vibetype.contact;

COMMIT;
