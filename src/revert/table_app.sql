BEGIN;

DROP POLICY app_select ON vibetype.app;

REVOKE ALL PRIVILEGES ON TABLE vibetype.app FROM vibetype_account;
REVOKE ALL PRIVILEGES ON TABLE vibetype.app FROM vibetype_anonymous;

DROP INDEX vibetype.idx_app_created_by;

DROP TABLE vibetype.app;

COMMIT;
