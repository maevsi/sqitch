BEGIN;

CREATE TABLE vibetype.preference_notification (
  id               UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  account_id       UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,
  is_push_enabled  BOOLEAN NOT NULL,
  type             vibetype.notification_type NOT NULL,

  created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE (account_id, type)
);

CREATE INDEX idx_preference_notification_account_id ON vibetype.preference_notification USING btree (account_id);

COMMENT ON TABLE vibetype.preference_notification IS 'Whether an account wants push notifications per notification type. A missing row means push is enabled.';
COMMENT ON COLUMN vibetype.preference_notification.id IS E'@behavior -insert -update\nThe preference''s internal id.';
COMMENT ON COLUMN vibetype.preference_notification.account_id IS E'@behavior -update\nThe account the preference belongs to.';
COMMENT ON COLUMN vibetype.preference_notification.is_push_enabled IS 'Whether push notifications of the type are delivered.';
COMMENT ON COLUMN vibetype.preference_notification.type IS E'@behavior -update\nThe notification type the preference applies to.';
COMMENT ON COLUMN vibetype.preference_notification.created_at IS E'@behavior -insert -update\nThe timestamp when the preference was created.';

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

GRANT SELECT, DELETE ON TABLE vibetype.preference_notification TO vibetype_account;
GRANT INSERT (account_id, is_push_enabled, type) ON TABLE vibetype.preference_notification TO vibetype_account;
GRANT UPDATE (is_push_enabled) ON TABLE vibetype.preference_notification TO vibetype_account;
GRANT SELECT ON TABLE vibetype.preference_notification TO :role_service_vibetype_username;

ALTER TABLE vibetype.preference_notification ENABLE ROW LEVEL SECURITY;

CREATE POLICY preference_notification_all ON vibetype.preference_notification FOR ALL
TO vibetype_account
USING (
  account_id = (SELECT vibetype.invoker_account_id())
);

CREATE POLICY preference_notification_service_vibetype_select ON vibetype.preference_notification FOR SELECT
TO :role_service_vibetype_username
USING (
  TRUE
);

COMMIT;
