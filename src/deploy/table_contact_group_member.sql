BEGIN;

CREATE TABLE vibetype.contact_group_member (
  contact_group_id  UUID NOT NULL REFERENCES vibetype.contact_group(id) ON DELETE CASCADE,
  contact_id        UUID NOT NULL REFERENCES vibetype.contact(id) ON DELETE CASCADE,

  PRIMARY KEY (contact_group_id, contact_id)
);

CREATE INDEX idx_contact_group_member_contact_id ON vibetype.contact_group_member USING btree (contact_id);

COMMENT ON TABLE vibetype.contact_group_member IS E'@behavior -update\nMapping contacts to contact groups (M:N relationship).';
COMMENT ON COLUMN vibetype.contact_group_member.contact_group_id IS 'A contact group id.';
COMMENT ON COLUMN vibetype.contact_group_member.contact_id IS 'A contact id.';

GRANT SELECT, DELETE ON TABLE vibetype.contact_group_member TO vibetype_account;
GRANT INSERT (contact_group_id, contact_id) ON TABLE vibetype.contact_group_member TO vibetype_account;

ALTER TABLE vibetype.contact_group_member ENABLE ROW LEVEL SECURITY;

CREATE POLICY contact_group_member_select ON vibetype.contact_group_member FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.contact_group g
    WHERE g.id = contact_group_member.contact_group_id
      AND g.created_by = (SELECT vibetype.invoker_account_id())
  )
);

CREATE POLICY contact_group_member_insert ON vibetype.contact_group_member FOR INSERT
WITH CHECK (
  EXISTS (
    SELECT 1
    FROM vibetype.contact_group g
    WHERE g.id = contact_group_member.contact_group_id
      AND g.created_by = (SELECT vibetype.invoker_account_id())
  )
  AND EXISTS (
    SELECT 1
    FROM vibetype.contact c
    WHERE c.id = contact_group_member.contact_id
      AND c.created_by = (SELECT vibetype.invoker_account_id())
  )
);

CREATE POLICY contact_group_member_delete ON vibetype.contact_group_member FOR DELETE
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.contact_group g
    WHERE g.id = contact_group_member.contact_group_id
      AND g.created_by = (SELECT vibetype.invoker_account_id())
  )
);

COMMIT;
