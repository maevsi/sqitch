BEGIN;

SELECT id,
       account_id,
       address,
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
       created_at,
       created_by
FROM maevsi.contact WHERE FALSE;

ROLLBACK;
