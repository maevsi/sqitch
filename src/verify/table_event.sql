BEGIN;

SELECT id,
       address_id,
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

SELECT maevsi_test.index_existence(
  ARRAY ['idx_event_location', 'idx_event_created_by', 'idx_event_search_vector']
);

ROLLBACK;
