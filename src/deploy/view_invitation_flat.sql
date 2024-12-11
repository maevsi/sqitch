-- Deploy maevsi:view_invitation_flat to pg
-- requires: schema_public
-- requires: table_invitation
-- requires: table_contact

BEGIN;
CREATE VIEW maevsi.invitation_flat AS
SELECT i.*,
  c.account_id as contact_account_id, c.address, c.author_account_id as contact_author_account_id, c.email_address, c.email_address_hash,
  c.first_name, c.last_name, c.phone_number, c.url as contact_url,
  e.author_account_id as event_author_account_id, e.description, e.start, e.end,
  e.invitee_count_maximum, e.is_archived, e.is_in_person, e.is_remote,
  e.location, e.name, e.slug, e.url as event_url, e.visibility
FROM maevsi.invitation i
  JOIN maevsi.contact c ON i.contact_id = c.id
  JOIN maevsi.event e ON i.event_id = e.id
;

COMMENT ON VIEW maevsi.invitation_flat IS 'View returning flattened invitations.';

END;
