BEGIN;

DROP POLICY profile_picture_upload_own ON vibetype.profile_picture;
DROP FUNCTION vibetype_private.upload_is_own(UUID);

COMMIT;
