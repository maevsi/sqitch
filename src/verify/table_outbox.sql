BEGIN;

SELECT id,
       aggregate_type,
       aggregate_id,
       type,
       is_acknowledged,
       payload,
       created_at
FROM vibetype_private.outbox WHERE FALSE;

ROLLBACK;
