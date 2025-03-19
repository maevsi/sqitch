BEGIN;

SELECT
  -- inherited from vibetype.notification
  id,
  channel,
  is_acknowledged,
  payload,
  created_at,
  -- columns specific for vibetype.invitation
  guest_id,
  created_by
FROM vibetype.invitation
WHERE FALSE;

ROLLBACK;
