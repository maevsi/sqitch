BEGIN;

REVOKE UPDATE (feedback, feedback_paper) ON TABLE vibetype.guest FROM vibetype_account, vibetype_anonymous;
GRANT UPDATE ON TABLE vibetype.guest TO vibetype_account, vibetype_anonymous;

COMMIT;
