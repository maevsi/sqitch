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
       created_by,
       search_vector
FROM vibetype.event WHERE FALSE;

SELECT vibetype_test.index_existence(
  ARRAY ['event_created_by_slug_key', 'idx_event_search_vector']
);

ROLLBACK;
