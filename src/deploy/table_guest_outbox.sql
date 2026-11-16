BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype.trigger_guest_outbox() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
BEGIN
  PERFORM vibetype_private.outbox_insert(
    'guest',
    NEW.id,
    'guest.accepted',
    jsonb_build_object(
      'guest_id', NEW.id,
      'event_id', NEW.event_id,
      'contact_id', NEW.contact_id
    )
  );

  RETURN NULL;
END;
$$;

COMMENT ON FUNCTION vibetype.trigger_guest_outbox() IS 'Adds an outbox event of type `guest.accepted`.';

GRANT EXECUTE ON FUNCTION vibetype.trigger_guest_outbox() TO vibetype_account, vibetype_anonymous;

-- Leaving ghost mode later stays silent, so switching it back and forth cannot repeat the notification.
CREATE TRIGGER outbox_accepted
  AFTER UPDATE OF feedback
  ON vibetype.guest
  FOR EACH ROW
  WHEN (
    NEW.feedback = 'accepted'::vibetype.invitation_feedback
    AND OLD.feedback IS DISTINCT FROM NEW.feedback
    AND NOT NEW.is_ghost
  )
  EXECUTE FUNCTION vibetype.trigger_guest_outbox();

CREATE FUNCTION vibetype_private.outbox_guest_acceptance_resolve(guest_id uuid) RETURNS TABLE (
  attendee_username text,
  event_creator_username text,
  event_name text,
  event_slug text,
  recipient_account_id uuid,
  recipient_language text
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT
    attendee.username,
    creator.username,
    e.name,
    e.slug,
    recipient.id,
    recipient_contact.language::text
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  JOIN vibetype.account attendee ON attendee.id = c.account_id
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.account creator ON creator.id = e.created_by
  JOIN vibetype.close_friend cf ON cf.created_by = attendee.id
  JOIN vibetype.friendship f ON f.id = cf.friendship_id
  JOIN vibetype.account recipient ON recipient.id = CASE WHEN f.account_a_id = attendee.id THEN f.account_b_id ELSE f.account_a_id END
  LEFT JOIN vibetype.contact recipient_contact ON recipient_contact.account_id = recipient.id AND recipient_contact.created_by = recipient.id
  WHERE g.id = outbox_guest_acceptance_resolve.guest_id
    AND g.feedback = 'accepted'::vibetype.invitation_feedback
    AND NOT g.is_ghost
    AND g.updated_by = attendee.id
    -- events of other visibilities could be ones the recipient cannot see
    AND e.visibility = 'public'::vibetype.event_visibility
    AND f.status = 'accepted'::vibetype.friendship_status
    AND NOT EXISTS (
      SELECT 1
      FROM vibetype.account_block ab
      WHERE (ab.created_by = recipient.id AND ab.blocked_account_id IN (attendee.id, creator.id))
        OR (ab.blocked_account_id = recipient.id AND ab.created_by IN (attendee.id, creator.id))
    );
$$;

COMMENT ON FUNCTION vibetype_private.outbox_guest_acceptance_resolve(UUID) IS 'Returns one row per friend that the attendee of a `guest.accepted` outbox event marked as close, with the data a notification about the attendance needs. Returns no row unless the guest''s own account accepted, is not in ghost mode and the event is public. Omits friends involved in a block with the attendee or the event''s creator. A recipient''s language is the one of the contact the recipient keeps of itself and may be missing.';

GRANT EXECUTE ON FUNCTION vibetype_private.outbox_guest_acceptance_resolve(UUID) TO :role_service_vibetype_username;

COMMIT;
