BEGIN;

SELECT account_id, email_address_id, is_primary, verification, verification_valid_until, created_at
FROM vibetype_private.account_email_address WHERE FALSE;

COMMIT;
