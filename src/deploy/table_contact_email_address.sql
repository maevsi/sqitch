BEGIN;

CREATE TABLE vibetype.contact_email_address (
  contact_id        UUID NOT NULL REFERENCES vibetype.contact(id) ON DELETE CASCADE,
  email_address_id  UUID NOT NULL REFERENCES vibetype_private.email_address(id) ON DELETE CASCADE,

  is_primary         BOOLEAN NOT NULL DEFAULT TRUE,

  PRIMARY KEY (contact_id, email_address_id)
);

CREATE UNIQUE INDEX idx_contact_email_address_primary ON vibetype.contact_email_address USING btree (contact_id) WHERE is_primary;
CREATE INDEX idx_contact_email_address_email_address_id ON vibetype.contact_email_address USING btree (email_address_id);

COMMENT ON TABLE vibetype.contact_email_address IS 'Links a contact to an email address it lists. No verification: contacts describe third parties, so nobody proves ownership of the address before it can be listed. Modeled as a many-to-many join so a future "multiple emails per contact" feature is additive; today, exactly one is_primary row exists per contact.';
COMMENT ON COLUMN vibetype.contact_email_address.contact_id IS 'The contact''s id.';
COMMENT ON COLUMN vibetype.contact_email_address.email_address_id IS 'The listed email address''s id.';
COMMENT ON COLUMN vibetype.contact_email_address.is_primary IS 'Whether this is the contact''s primary email address. At most one primary address per contact.';
COMMENT ON INDEX vibetype.idx_contact_email_address_primary IS 'Ensures at most one primary email address per contact.';

GRANT SELECT ON TABLE vibetype.contact_email_address TO vibetype_anonymous;
GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE vibetype.contact_email_address TO vibetype_account;

ALTER TABLE vibetype.contact_email_address ENABLE ROW LEVEL SECURITY;

CREATE POLICY contact_email_address_all ON vibetype.contact_email_address FOR ALL
USING (
  EXISTS (
    SELECT 1 FROM vibetype.contact c
    WHERE c.id = contact_email_address.contact_id
      AND c.created_by = vibetype.invoker_account_id()
  )
);

-- Keeps contact_identity_check's invariant (a contact must be reachable via a linked account or
-- at least one email address) intact when a contact's last email address link is removed.
CREATE FUNCTION vibetype.trigger_contact_email_address_identity_check() RETURNS TRIGGER
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  PERFORM vibetype.contact_identity_check(OLD.contact_id);
  RETURN NULL;
END;
$$;

CREATE CONSTRAINT TRIGGER contact_identity_check
  AFTER DELETE ON vibetype.contact_email_address
  DEFERRABLE INITIALLY DEFERRED
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_contact_email_address_identity_check();

-- Both account_email_address and contact_email_address now exist, so email_address's own read
-- access can be scoped to whichever addresses the caller is entitled to see through either join
-- (their own account's, or their own contacts'), instead of leaving that private schema
-- unreadable to vibetype_account/vibetype_anonymous entirely.
GRANT SELECT ON TABLE vibetype_private.email_address TO vibetype_account, vibetype_anonymous;

CREATE POLICY email_address_select ON vibetype_private.email_address FOR SELECT
USING (
  EXISTS (
    SELECT 1 FROM vibetype_private.account_email_address aea
    WHERE aea.email_address_id = email_address.id AND aea.account_id = vibetype.invoker_account_id()
  )
  OR
  EXISTS (
    SELECT 1 FROM vibetype.contact_email_address cea
    JOIN vibetype.contact c ON c.id = cea.contact_id
    WHERE cea.email_address_id = email_address.id AND c.created_by = vibetype.invoker_account_id()
  )
);

COMMIT;
