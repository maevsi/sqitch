BEGIN;

CREATE TABLE vibetype.account_notification (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id        UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  actor_account_id  UUID REFERENCES vibetype.account(id) ON DELETE CASCADE,
  event_id          UUID REFERENCES vibetype.event(id) ON DELETE CASCADE,
  friendship_id     UUID REFERENCES vibetype.friendship(id) ON DELETE CASCADE,
  guest_id          UUID REFERENCES vibetype.guest(id) ON DELETE CASCADE,
  payload           JSONB NOT NULL DEFAULT '{}'::JSONB,
  read_at           TIMESTAMP WITH TIME ZONE,
  type              vibetype.notification_type NOT NULL,

  created_at        TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_account_notification_account_id_created_at ON vibetype.account_notification USING btree (account_id, created_at DESC);
CREATE INDEX idx_account_notification_account_id_unread ON vibetype.account_notification USING btree (account_id) WHERE read_at IS NULL;
CREATE INDEX idx_account_notification_actor_account_id ON vibetype.account_notification USING btree (actor_account_id);
CREATE INDEX idx_account_notification_event_id ON vibetype.account_notification USING btree (event_id);
CREATE INDEX idx_account_notification_friendship_id ON vibetype.account_notification USING btree (friendship_id);
CREATE INDEX idx_account_notification_guest_id ON vibetype.account_notification USING btree (guest_id);

COMMENT ON TABLE vibetype.account_notification IS E'@behavior -insert\nA notification in the inbox of an account. Rows are created by database triggers only.';
COMMENT ON COLUMN vibetype.account_notification.id IS E'@behavior -insert -update\nThe notification''s internal id.';
COMMENT ON COLUMN vibetype.account_notification.account_id IS E'@behavior -insert -update\nThe account that receives the notification.';
COMMENT ON COLUMN vibetype.account_notification.actor_account_id IS E'@behavior -insert -update\nThe account that caused the notification. `NULL` if an anonymous guest caused it.';
COMMENT ON COLUMN vibetype.account_notification.event_id IS E'@behavior -insert -update\nThe event the notification is about. `NULL` for deleted events and friendships.';
COMMENT ON COLUMN vibetype.account_notification.friendship_id IS E'@behavior -insert -update\nThe friendship the notification is about. The notification is removed with the friendship, e.g. when a request is declined.';
COMMENT ON COLUMN vibetype.account_notification.guest_id IS E'@behavior -insert -update\nThe guest the notification is about.';
COMMENT ON COLUMN vibetype.account_notification.payload IS E'@behavior -insert -update\nA snapshot of what is needed to render the notification. Possible keys: `actor_username`, `changes`, `event_creator_username`, `event_name`, `event_slug`, `event_start`, `feedback`, `guest_name`.';
COMMENT ON COLUMN vibetype.account_notification.read_at IS E'@behavior -insert\nThe timestamp when the recipient read the notification. `NULL` while unread.';
COMMENT ON COLUMN vibetype.account_notification.type IS E'@behavior -insert -update\nThe kind of the notification.';
COMMENT ON COLUMN vibetype.account_notification.created_at IS E'@behavior -insert -update\nThe timestamp when the notification was created.';
COMMENT ON INDEX vibetype.idx_account_notification_account_id_created_at IS 'B-Tree index to optimize listing an inbox by recency.';
COMMENT ON INDEX vibetype.idx_account_notification_account_id_unread IS 'Partial B-Tree index to optimize counting unread notifications.';

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

GRANT SELECT, DELETE ON TABLE vibetype.account_notification TO vibetype_account;
GRANT UPDATE (read_at) ON TABLE vibetype.account_notification TO vibetype_account;
GRANT SELECT ON TABLE vibetype.account_notification TO :role_service_vibetype_username;

ALTER TABLE vibetype.account_notification ENABLE ROW LEVEL SECURITY;

-- Hide notifications caused by an account that is blocked in either direction.
CREATE POLICY account_notification_select ON vibetype.account_notification FOR SELECT
TO vibetype_account
USING (
  account_id = (SELECT vibetype.invoker_account_id())
  AND (
    actor_account_id IS NULL
    OR NOT (actor_account_id = ANY ((SELECT vibetype_private.account_block_ids())::UUID[]))
  )
);

CREATE POLICY account_notification_update ON vibetype.account_notification FOR UPDATE
TO vibetype_account
USING (
  account_id = (SELECT vibetype.invoker_account_id())
);

CREATE POLICY account_notification_delete ON vibetype.account_notification FOR DELETE
TO vibetype_account
USING (
  account_id = (SELECT vibetype.invoker_account_id())
);

CREATE POLICY account_notification_service_vibetype_select ON vibetype.account_notification FOR SELECT
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
