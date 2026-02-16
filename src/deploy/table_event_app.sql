BEGIN;

CREATE TABLE vibetype.event_app (
  id            uuid DEFAULT gen_random_uuid() PRIMARY KEY,

  app_id        uuid NOT NULL REFERENCES vibetype.app(id) ON DELETE CASCADE,
  event_id      uuid NOT NULL REFERENCES vibetype.event(id) ON DELETE CASCADE,

  created_at    timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_by    uuid NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  UNIQUE (event_id, app_id)
);

CREATE INDEX idx_event_app_created_by ON vibetype.event_app USING btree (created_by);

COMMENT ON TABLE vibetype.event_app IS E'@behavior -insert -update -delete\nRecords which apps are installed on which events.';
COMMENT ON COLUMN vibetype.event_app.id IS E'@behavior -insert -update\nA unique reference for this installation.';
COMMENT ON COLUMN vibetype.event_app.app_id IS E'@behavior -update\nThe app that is installed.';
COMMENT ON COLUMN vibetype.event_app.event_id IS E'@behavior -update\nThe event the app is installed on.';
COMMENT ON COLUMN vibetype.event_app.created_at IS E'@behavior -insert -update\nWhen the app was installed.';
COMMENT ON COLUMN vibetype.event_app.created_by IS E'@behavior -update\nWho installed this app.';
COMMENT ON INDEX vibetype.idx_event_app_created_by IS 'B-Tree index to optimize lookups by creator.';

GRANT SELECT ON TABLE vibetype.event_app TO vibetype_anonymous;
GRANT SELECT ON TABLE vibetype.event_app TO vibetype_account;

ALTER TABLE vibetype.event_app ENABLE ROW LEVEL SECURITY;

CREATE POLICY event_app_select ON vibetype.event_app FOR SELECT
USING (
  EXISTS (
    SELECT 1
    FROM vibetype.event e
    WHERE e.id = event_id
  )
);

COMMIT;
