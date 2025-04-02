BEGIN;

SELECT
  -- inherited from vibetype.notification
  id,
  channel,
  is_acknowledged,
  payload,
  created_by,
  created_at,
  -- columns specific for vibetype.notification_invitation
  guest_id
FROM vibetype.notification_invitation
WHERE FALSE;

ROLLBACK;
