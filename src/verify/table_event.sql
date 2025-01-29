BEGIN;

SELECT id,
       description,
       "end",
       guest_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       location,
       location_geography,
       name,
       slug,
       start,
       url,
       visibility,
       created_at,
       created_by,
       search_vector
FROM maevsi.event WHERE FALSE;

ROLLBACK;
