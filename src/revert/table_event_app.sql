BEGIN;

DROP POLICY event_app_select ON vibetype.event_app;

REVOKE ALL PRIVILEGES ON TABLE vibetype.event_app FROM vibetype_account;
REVOKE ALL PRIVILEGES ON TABLE vibetype.event_app FROM vibetype_anonymous;

DROP INDEX vibetype.idx_event_app_created_by;

DROP TABLE vibetype.event_app;

COMMIT;
