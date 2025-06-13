BEGIN;

REVOKE SELECT ON TABLE vibetype.event_favorite FROM vibetype_anonymous;

COMMIT;
