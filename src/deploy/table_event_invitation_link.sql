BEGIN;

CREATE TABLE vibetype.event_invitation_link (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  event_id    UUID NOT NULL UNIQUE REFERENCES vibetype.event(id) ON DELETE CASCADE,

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

COMMENT ON TABLE vibetype.event_invitation_link IS E'@behavior -update\nA general invitation link that lets anyone holding it join an event as a guest. Deleting it pauses the link, and creating a new one resets it.';
COMMENT ON COLUMN vibetype.event_invitation_link.id IS E'@behavior -insert\nThe link''s secret code and primary key.';
COMMENT ON COLUMN vibetype.event_invitation_link.event_id IS 'Reference to the event the link invites to.';
COMMENT ON COLUMN vibetype.event_invitation_link.created_at IS E'@behavior -insert\nTimestamp when the link was created. Defaults to the current timestamp.';
COMMENT ON CONSTRAINT event_invitation_link_event_id_key ON vibetype.event_invitation_link IS 'Ensures that an event has at most one invitation link, which also indexes the reference to the event.';

GRANT SELECT, DELETE ON TABLE vibetype.event_invitation_link TO vibetype_account;
GRANT INSERT (event_id) ON TABLE vibetype.event_invitation_link TO vibetype_account;

ALTER TABLE vibetype.event_invitation_link ENABLE ROW LEVEL SECURITY;

-- Only the organizer sees the code, as anyone holding it can join.
CREATE POLICY event_invitation_link_all ON vibetype.event_invitation_link FOR ALL
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = event_invitation_link.event_id
      AND e.created_by = (SELECT vibetype.invoker_account_id())
  )
);

COMMIT;
