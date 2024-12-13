BEGIN;
CREATE VIEW maevsi.invitation_flat WITH (security_invoker) AS
  SELECT
    invitation.id               AS invitation_id,
    invitation.contact_id       AS invitation_contact_id,
    invitation.event_id         AS invitation_event_id,
    invitation.feedback         AS invitation_feedback,
    invitation.feedback_paper   AS invitation_feedback_paper,

    contact.id                  AS contact_id,
    contact.account_id          AS contact_account_id,
    contact.address             AS contact_address,
    contact.author_account_id   AS contact_author_account_id,
    contact.email_address       AS contact_email_address,
    contact.email_address_hash  AS contact_email_address_hash,
    contact.first_name          AS contact_first_name ,
    contact.last_name           AS contact_last_name,
    contact.phone_number        AS contact_phone_number,
    contact.url                 AS contact_url,

    event.id                    AS event_id,
    event.author_account_id     AS event_author_account_id,
    event.description           AS event_description,
    event.start                 AS event_start,
    event.end                   AS event_end,
    event.invitee_count_maximum AS event_invitee_count_maximum,
    event.is_archived           AS event_is_archived,
    event.is_in_person          AS event_is_in_person,
    event.is_remote             AS event_is_remote,
    event.location              AS event_location,
    event.name                  AS event_name,
    event.slug                  AS event_slug,
    event.url                   AS event_url,
    event.visibility            AS event_visibility
  FROM maevsi.invitation
    JOIN maevsi.contact ON invitation.contact_id = contact.id
    JOIN maevsi.event   ON invitation.event_id   = event.id;

COMMENT ON VIEW maevsi.invitation_flat IS 'View returning flattened invitations.';

GRANT SELECT ON maevsi.invitation_flat TO maevsi_account, maevsi_anonymous;

END;
