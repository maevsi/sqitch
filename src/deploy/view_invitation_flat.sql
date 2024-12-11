-- Deploy maevsi:view_invitation_flat to pg
-- requires: schema_public
-- requires: table_invitation
-- requires: table_contact

BEGIN;
CREATE VIEW maevsi.invitation_flat AS
SELECT i.*,
  c.account_id as contact_account_id, c.address as contact_address,
  c.author_account_id as contact_author_account_id,
  c.email_address as contact_email_address, c.email_address_hash as contact_email_address_hash,
  c.first_name as contact_first_name , c.last_name as contact_last_name,
  c.phone_number as contact_phone_number, c.url as contact_url,
  e.author_account_id as event_author_account_id, e.description as event_description,
  e.start as event_start, e.end event_end, e.invitee_count_maximum as event_invitee_count_maximum,
  e.is_archived as event_is_archived, e.is_in_person as event_is_in_person, e.is_remote as event_is_remote,
  e.location as event_location, e.name as event_name, e.slug as event_slug, e.url as event_url,
  e.visibility as event_visibility
FROM maevsi.invitation i
  JOIN maevsi.contact c ON i.contact_id = c.id
  JOIN maevsi.event e ON i.event_id = e.id
;

COMMENT ON VIEW maevsi.invitation_flat IS 'View returning flattened invitations.';

END;
