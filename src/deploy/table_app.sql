BEGIN;

CREATE TABLE vibetype.app (
  id                uuid DEFAULT gen_random_uuid() PRIMARY KEY,

  name              text NOT NULL CHECK (((char_length(name) > 0) AND (char_length(name) <= 100))),
  icon_svg          text NOT NULL CHECK (((char_length(icon_svg) > 0) AND (char_length(icon_svg) <= 50000))),
  url               text NOT NULL CHECK (((char_length(url) > 0) AND (char_length(url) <= 2000) AND (url ~ '^https://[^[:space:]]+$'))),
  url_attendance    text NOT NULL CHECK (((char_length(url_attendance) > 0) AND (char_length(url_attendance) <= 2000) AND (url_attendance ~ '^https://[^[:space:]]+$'))),

  created_at        timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  created_by        uuid REFERENCES vibetype.account(id) ON DELETE CASCADE NOT NULL,

  UNIQUE (name)
);

CREATE INDEX idx_app_created_by ON vibetype.app USING btree (created_by);

COMMENT ON TABLE vibetype.app IS E'@behavior -insert -update -delete\nIntegrations that can be added to events. Each app has a name, icon, and an endpoint for attendance management.';
COMMENT ON COLUMN vibetype.app.id IS 'A unique reference for this app.';
COMMENT ON COLUMN vibetype.app.name IS 'The name of the app.';
COMMENT ON COLUMN vibetype.app.icon_svg IS 'An SVG icon for displaying the app.';
COMMENT ON COLUMN vibetype.app.url IS 'The main URL of the app.';
COMMENT ON COLUMN vibetype.app.url_attendance IS 'The URL endpoint for managing attendance.';
COMMENT ON COLUMN vibetype.app.created_at IS 'When the app was created.';
COMMENT ON COLUMN vibetype.app.created_by IS 'Who created this app.';
COMMENT ON INDEX vibetype.idx_app_created_by IS 'B-Tree index to optimize lookups by creator.';

GRANT SELECT ON TABLE vibetype.app TO vibetype_account;
GRANT SELECT ON TABLE vibetype.app TO vibetype_anonymous;

ALTER TABLE vibetype.app ENABLE ROW LEVEL SECURITY;

CREATE POLICY app_select ON vibetype.app FOR SELECT
USING (TRUE);

COMMIT;
