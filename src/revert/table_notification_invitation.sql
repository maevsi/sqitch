BEGIN;

DROP POLICY notification_invitation_all ON vibetype.notification_invitation;
DROP POLICY notification_invitation_insert ON vibetype.notification_invitation;

DROP TABLE vibetype.notification_invitation;

COMMIT;
