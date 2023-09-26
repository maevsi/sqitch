-- Verify maevsi:table_contact on pg

BEGIN;

SELECT id,
       account_id,
       "address",
       author_account_id,
       email_address,
       email_address_hash,
       first_name,
       last_name,
       phone_number,
       "url"
FROM maevsi.contact WHERE FALSE;

ROLLBACK;
