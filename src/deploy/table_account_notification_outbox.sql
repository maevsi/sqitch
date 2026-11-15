BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype_private.trigger_account_notification_outbox() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM vibetype_private.outbox_insert('account_notification', NEW.id, 'account_notification.created', '{}'::jsonb);

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype_private.trigger_account_notification_outbox() IS 'Adds an outbox event of type `account_notification.created` without data, so no personal data leaves the database. Consumers resolve the notification by its id.';
REVOKE ALL ON FUNCTION vibetype_private.trigger_account_notification_outbox() FROM PUBLIC;

CREATE TRIGGER outbox
  AFTER
    INSERT
  ON vibetype.account_notification
  FOR EACH ROW
  EXECUTE FUNCTION vibetype_private.trigger_account_notification_outbox();


CREATE FUNCTION vibetype_private.outbox_account_notification_resolve(account_notification_id uuid) RETURNS TABLE (
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
    COALESCE((SELECT array_agg(d.fcm_token) FROM vibetype.device d WHERE d.created_by = n.account_id), ARRAY[]::text[]),
    n.friendship_id,
    n.guest_id,
    COALESCE((SELECT p.is_push_enabled FROM vibetype.preference_notification p WHERE p.account_id = n.account_id AND p.type = n.type), TRUE),
    (SELECT c.language::text FROM vibetype.contact c WHERE c.account_id = n.account_id AND c.created_by = n.account_id),
    n.payload,
    n.type
  FROM vibetype.account_notification n
  WHERE n.id = outbox_account_notification_resolve.account_notification_id;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_account_notification_resolve(UUID) IS 'Returns the data that the push notification of an `account_notification.created` outbox event needs, or no row if the notification is gone, e.g. because it was deleted or replaced by a newer one.';

REVOKE ALL ON FUNCTION vibetype_private.outbox_account_notification_resolve(UUID) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION vibetype_private.outbox_account_notification_resolve(UUID) TO :role_service_vibetype_username;

-- The push consumer prunes tokens that Firebase reports as unregistered.
GRANT DELETE ON TABLE vibetype.device TO :role_service_vibetype_username;

CREATE POLICY device_service_vibetype_delete ON vibetype.device FOR DELETE
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
