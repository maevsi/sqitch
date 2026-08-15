BEGIN;

SELECT id, email_address_id, code, valid_until, confirmed_at, language, time_zone, created_at
FROM vibetype_private.email_address_verification WHERE FALSE;

COMMIT;
