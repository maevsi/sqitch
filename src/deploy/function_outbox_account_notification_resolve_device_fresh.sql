BEGIN;

CREATE OR REPLACE FUNCTION vibetype_private.outbox_account_notification_resolve(account_notification_id uuid) RETURNS TABLE (
  account_id uuid,
  event_id uuid,
  fcm_tokens text[],
  friendship_id uuid,
  guest_id uuid,
  is_push_enabled boolean,
  language text,
  payload jsonb,
  type vibetype.notification_type
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT
    n.account_id,
    n.event_id,
    COALESCE((SELECT array_agg(d.fcm_token) FROM vibetype.device d WHERE d.created_by = n.account_id AND d.last_seen_at > CURRENT_TIMESTAMP - INTERVAL '90 days'), ARRAY[]::text[]),
    n.friendship_id,
    n.guest_id,
    COALESCE((SELECT p.is_push_enabled FROM vibetype.preference_notification p WHERE p.account_id = n.account_id AND p.type = n.type), TRUE),
    (SELECT c.language::text FROM vibetype.contact c WHERE c.account_id = n.account_id AND c.created_by = n.account_id),
    n.payload,
    n.type
  FROM vibetype.account_notification n
  WHERE n.id = outbox_account_notification_resolve.account_notification_id;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_account_notification_resolve(UUID) IS 'Returns the data that the push notification of an `account_notification.created` outbox event needs, or no row if the notification is gone, e.g. because it was deleted or replaced by a newer one. Devices that were not seen for 90 days are left out of `fcm_tokens`.';

COMMIT;
