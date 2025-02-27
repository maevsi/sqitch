BEGIN;
CREATE VIEW maevsi.guest_flat WITH (security_invoker) AS
  SELECT
    guest.id                    AS guest_id,
    guest.contact_id            AS guest_contact_id,
    guest.event_id              AS guest_event_id,
    guest.feedback              AS guest_feedback,
    guest.feedback_paper        AS guest_feedback_paper,

    contact.id                  AS contact_id,
    contact.account_id          AS contact_account_id,
    contact.address_id          AS contact_address_id,
    contact.email_address       AS contact_email_address,
    contact.email_address_hash  AS contact_email_address_hash,
    contact.first_name          AS contact_first_name ,
    contact.last_name           AS contact_last_name,
    contact.phone_number        AS contact_phone_number,
    contact.url                 AS contact_url,
    contact.created_by          AS contact_created_by,

    event.id                    AS event_id,
    event.address_id            AS event_address_id,
    event.description           AS event_description,
    event.start                 AS event_start,
    event.end                   AS event_end,
    event.guest_count_maximum   AS event_guest_count_maximum,
    event.is_archived           AS event_is_archived,
    event.is_in_person          AS event_is_in_person,
    event.is_remote             AS event_is_remote,
    event.name                  AS event_name,
    event.slug                  AS event_slug,
    event.url                   AS event_url,
    event.visibility            AS event_visibility,
    event.created_by            AS event_created_by
  FROM maevsi.guest
    JOIN maevsi.contact ON guest.contact_id = contact.id
    JOIN maevsi.event   ON guest.event_id   = event.id;

COMMENT ON VIEW maevsi.guest_flat IS 'View returning flattened guests.';

GRANT SELECT ON maevsi.guest_flat TO maevsi_account, maevsi_anonymous;

END;
