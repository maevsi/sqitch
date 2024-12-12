BEGIN;
CREATE VIEW maevsi.invitation_flat
WITH (security_invoker)
AS SELECT
  i.id AS invitation_id,
  i.contact_id AS invitation_contact_id,
  i.event_id AS invitation_event_id,
  i.feedback AS invitation_feedback,
  i.feedback_paper AS invitation_feedback_paper,
  c.id AS contact_id,
  c.account_id AS contact_account_id,
  c.address AS contact_address,
  c.author_account_id AS contact_author_account_id,
  c.email_address AS contact_email_address,
  c.email_address_hash AS contact_email_address_hash,
  c.first_name AS contact_first_name ,
  c.last_name AS contact_last_name,
  c.phone_number AS contact_phone_number,
  c.url AS contact_url,
  e.id AS event_id,
  e.author_account_id AS event_author_account_id,
  e.description AS event_description,
  e.start AS event_start,
  e.end AS event_end,
  e.invitee_count_maximum AS event_invitee_count_maximum,
  e.is_archived AS event_is_archived,
  e.is_in_person AS event_is_in_person,
  e.is_remote AS event_is_remote,
  e.location AS event_location,
  e.name AS event_name,
  e.slug AS event_slug,
  e.url AS event_url,
  e.visibility AS event_visibility
FROM maevsi.invitation i
  JOIN maevsi.contact c ON i.contact_id = c.id
  JOIN maevsi.event e ON i.event_id = e.id;

COMMENT ON VIEW maevsi.invitation_flat IS 'View returning flattened invitations.';

GRANT SELECT ON maevsi.invitation_flat TO maevsi_account, maevsi_anonymous;

END;
