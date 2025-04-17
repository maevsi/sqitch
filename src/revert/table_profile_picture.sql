BEGIN;

DROP POLICY profile_picture_all ON vibetype.profile_picture;
DROP POLICY profile_picture_select ON vibetype.profile_picture;
DROP POLICY profile_picture_delete_service ON vibetype.profile_picture;

DROP TABLE vibetype.profile_picture;

COMMIT;
