BEGIN;

DROP INDEX vibetype_private.idx_jwt_updated_by;
DROP INDEX vibetype_private.idx_jwt_subject;

DROP TABLE vibetype_private.jwt;

COMMIT;
