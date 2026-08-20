BEGIN;

DROP TABLE vibetype_private.account_email_address;
DROP FUNCTION vibetype_private.trigger_account_email_address_verification_valid_until();

COMMIT;
