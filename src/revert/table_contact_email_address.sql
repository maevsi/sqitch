BEGIN;

DROP POLICY email_address_select ON vibetype_private.email_address;
DROP FUNCTION vibetype_private.email_address_readable(UUID);
REVOKE SELECT ON TABLE vibetype_private.email_address FROM vibetype_account, vibetype_anonymous;
REVOKE USAGE ON SCHEMA vibetype_private FROM vibetype_account, vibetype_anonymous;

DROP TRIGGER contact_identity_check ON vibetype.contact_email_address;
DROP FUNCTION vibetype.trigger_contact_email_address_identity_check();
DROP TABLE vibetype.contact_email_address;

COMMIT;
