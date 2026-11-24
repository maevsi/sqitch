BEGIN;

DROP FUNCTION vibetype.create_contact_group_members(UUID[], UUID[]);
DROP FUNCTION vibetype.create_contact_groups(TEXT[]);
DROP FUNCTION vibetype.create_contacts(vibetype.contact[]);

COMMIT;
