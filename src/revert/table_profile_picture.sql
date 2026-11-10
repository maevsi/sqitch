BEGIN;

DROP POLICY profile_picture_upload_own ON vibetype.profile_picture;
DROP FUNCTION vibetype_private.upload_is_own(UUID);

DROP POLICY profile_picture_all ON vibetype.profile_picture;
DROP POLICY profile_picture_select ON vibetype.profile_picture;
DROP POLICY profile_picture_delete_service ON vibetype.profile_picture;

DROP TABLE vibetype.profile_picture;

COMMIT;
