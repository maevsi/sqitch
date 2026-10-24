BEGIN;

-- A guest's event and contact are fixed once created, only the feedback columns are meant to change.
REVOKE UPDATE ON TABLE vibetype.guest FROM vibetype_account, vibetype_anonymous;
GRANT UPDATE (feedback, feedback_paper) ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;

COMMIT;
