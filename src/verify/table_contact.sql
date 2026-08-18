BEGIN;

SELECT id,
       account_deleted,
       account_id,
       address_id,
       first_name,
       language,
       last_name,
       nickname,
       note,
       phone_number,
       time_zone,
       url,
       created_at,
       created_by
FROM vibetype.contact WHERE FALSE;

ROLLBACK;
