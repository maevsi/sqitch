BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE FUNCTION vibetype_private.outbox_guest_invitation_resolve(guest_id uuid) RETURNS TABLE (
  contact_email_address text,
  contact_time_zone text,
  event jsonb,
  event_creator_username text,
  event_creator_profile_picture_upload_storage_key text
)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT
    COALESCE(ap.email_address, c.email_address),
    c.time_zone,
    jsonb_build_object(
      'id', e.id,
      'name', e.name,
      'slug', e.slug,
      'description', e.description,
      'start', e.start,
      'end', e."end",
      'guest_count_maximum', e.guest_count_maximum,
      'is_archived', e.is_archived,
      'is_in_person', e.is_in_person,
      'is_remote', e.is_remote,
      'visibility', e.visibility,
      'created_by', e.created_by
    ),
    a.username,
    u.storage_key
  FROM vibetype.guest g
  JOIN vibetype.contact c ON c.id = g.contact_id
  JOIN vibetype.event e ON e.id = g.event_id
  JOIN vibetype.account a ON a.id = e.created_by
  LEFT JOIN vibetype_private.account ap ON ap.id = c.account_id
  LEFT JOIN vibetype.profile_picture pp ON pp.account_id = e.created_by
  LEFT JOIN vibetype.upload u ON u.id = pp.upload_id
  WHERE g.id = outbox_guest_invitation_resolve.guest_id
    AND COALESCE(ap.email_address, c.email_address) IS NOT NULL;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_guest_invitation_resolve(UUID) IS 'Returns the data that the invitation email of a `guest.invited` outbox event needs, or no row if the guest, its contact or the contact''s email address is gone.';

GRANT EXECUTE ON FUNCTION vibetype_private.outbox_guest_invitation_resolve(UUID) TO :role_service_vibetype_username;

COMMIT;
