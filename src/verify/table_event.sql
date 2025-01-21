BEGIN;

SELECT id,
       created_at,
       author_account_id,
       description,
       "end",
       invitee_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       location,
       location_geometry,
       name,
       slug,
       start,
       url,
       visibility
FROM maevsi.event WHERE FALSE;

ROLLBACK;
