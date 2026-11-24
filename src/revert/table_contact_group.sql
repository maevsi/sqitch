BEGIN;

DROP POLICY contact_group_all ON vibetype.contact_group;

DROP TABLE vibetype.contact_group;

COMMIT;
