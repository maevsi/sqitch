BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_paper,
       created_at,
       updated_at,
       updated_by
FROM vibetype.guest WHERE FALSE;

SELECT vibetype_test.index_existence(
  ARRAY ['guest_event_id_contact_id_key', 'idx_guest_updated_by']
);

ROLLBACK;
