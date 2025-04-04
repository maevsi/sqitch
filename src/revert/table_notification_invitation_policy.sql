BEGIN;

DROP POLICY notification_invitation_insert ON vibetype.notification_invitation;
DROP POLICY notification_invitation_select ON vibetype.notification_invitation;

COMMIT;
