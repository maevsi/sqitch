BEGIN;

\set role_service_reccoom_username `cat /run/secrets/postgres_role_service_reccoom_username`

DROP POLICY event_select ON vibetype.event;
DROP FUNCTION vibetype_private.events_with_claimed_attendance();
DROP POLICY event_all ON vibetype.event;

REVOKE ALL PRIVILEGES ON TABLE vibetype.event FROM :role_service_reccoom_username;
REVOKE ALL PRIVILEGES ON TABLE vibetype.event FROM vibetype_account;
REVOKE ALL PRIVILEGES ON TABLE vibetype.event FROM vibetype_anonymous;

COMMIT;
