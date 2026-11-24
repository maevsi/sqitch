BEGIN;

DROP POLICY contact_group_member_select ON vibetype.contact_group_member;
DROP POLICY contact_group_member_insert ON vibetype.contact_group_member;
DROP POLICY contact_group_member_delete ON vibetype.contact_group_member;

DROP TABLE vibetype.contact_group_member;

COMMIT;
