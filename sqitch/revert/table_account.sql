-- Revert maevsi:table_account from pg

BEGIN;

DROP TRIGGER maevsi_private_account_password_reset_verification_valid_until ON maevsi_private.account;
DROP TRIGGER maevsi_private_account_email_address_verification_valid_until ON maevsi_private.account;
DROP FUNCTION maevsi_private.account_password_reset_verification_valid_until;
DROP FUNCTION maevsi_private.account_email_address_verification_valid_until;
DROP TABLE maevsi_private.account;

COMMIT;
