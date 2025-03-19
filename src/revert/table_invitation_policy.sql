BEGIN;

DROP POLICY invitation_insert ON vibetype.invitation;
DROP POLICY invitation_select ON vibetype.invitation;

COMMIT;
