BEGIN;

SELECT id,
       created_at,
       account_id,
       address,
       author_account_id,
       email_address,
       email_address_hash,
       first_name,
       language,
       last_name,
       nickname,
       phone_number,
       timezone,
       url
FROM maevsi.contact WHERE FALSE;

ROLLBACK;
