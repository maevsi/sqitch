BEGIN;

DROP POLICY event_invitation_link_all ON vibetype.event_invitation_link;

DROP TABLE vibetype.event_invitation_link;

COMMIT;
