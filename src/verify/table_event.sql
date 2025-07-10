BEGIN;

SELECT id,
       address_id,
       description,
       "end",
       guest_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       name,
       slug,
       start,
       url,
       visibility,
       created_at,
       created_by
FROM vibetype.event WHERE FALSE;


ROLLBACK;
