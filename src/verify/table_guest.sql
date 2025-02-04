BEGIN;

SELECT id,
       event_id,
       feedback,
       feedback_paper,
       created_at,
       updated_at,
       updated_by
FROM maevsi.guest WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['guest_event_id_contact_id_key', 'idx_guest_updated_by']
);

ROLLBACK;
