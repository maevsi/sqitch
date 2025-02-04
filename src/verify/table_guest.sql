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
  ARRAY ['idx_guest_contact_id', 'idx_guest_event_id']
);

ROLLBACK;
