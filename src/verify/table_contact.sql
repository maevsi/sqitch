BEGIN;

SELECT id,
       account_id,
       address,
       author_account_id,
       email_address,
       email_address_hash,
       first_name,
       language,
       last_name,
       nickname,
       note,
       phone_number,
       timezone,
       url,
       created_at
FROM maevsi.contact WHERE FALSE;

ROLLBACK;
