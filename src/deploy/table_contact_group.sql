BEGIN;

CREATE TABLE vibetype.contact_group (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  name        TEXT NOT NULL CHECK (char_length(name) > 0 AND char_length(name) <= 100),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by  UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE
);

CREATE UNIQUE INDEX idx_contact_group_created_by_name ON vibetype.contact_group (created_by, lower(name));

COMMENT ON TABLE vibetype.contact_group IS 'A private group an account sorts its contacts into, e.g. to filter the invitation contact picker.';
COMMENT ON COLUMN vibetype.contact_group.id IS E'@behavior -insert -update\nPrimary key, uniquely identifies each contact group.';
COMMENT ON COLUMN vibetype.contact_group.name IS 'Name of the group. Must be between 1 and 100 characters and unique per account, ignoring case.';
COMMENT ON COLUMN vibetype.contact_group.created_at IS E'@behavior -insert -update\nTimestamp when the group was created. Defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.contact_group.created_by IS E'@behavior -update\nReference to the account that created this group. Enforces cascading deletion.';
COMMENT ON INDEX vibetype.idx_contact_group_created_by_name IS 'Ensures that an account has each group name only once, ignoring case, which also indexes the reference to the account.';

GRANT SELECT, DELETE ON TABLE vibetype.contact_group TO vibetype_account;
GRANT INSERT (created_by, name), UPDATE (name) ON TABLE vibetype.contact_group TO vibetype_account;

ALTER TABLE vibetype.contact_group ENABLE ROW LEVEL SECURITY;

CREATE POLICY contact_group_all ON vibetype.contact_group FOR ALL
USING (created_by = (SELECT vibetype.invoker_account_id()));

COMMIT;
