BEGIN;

DROP TRIGGER password_reset_verification ON vibetype_private.account;
DROP TRIGGER email_address_verification ON vibetype_private.account;
DROP FUNCTION vibetype_private.trigger_account_password_reset_verification_valid_until();
DROP FUNCTION vibetype_private.trigger_account_email_address_verification_valid_until();
DROP INDEX vibetype_private.idx_account_private_location;
DROP TABLE vibetype_private.account;

COMMIT;
