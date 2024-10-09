-- Deploy maevsi:table_report to pg
-- requires: schema_public
-- requires: table_account_public
-- requires: table_event
-- requires: table_upload

BEGIN;

CREATE TABLE maevsi.report (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_account_id   UUID NOT NULL REFERENCES maevsi.account(id),
  reason              TEXT NOT NULL CHECK (char_length("reason") > 0 AND char_length("reason") < 2000),
  target_account_id   UUID REFERENCES maevsi.account(id),
  target_event_id     UUID REFERENCES maevsi.event(id),
  target_upload_id    UUID REFERENCES maevsi.upload(id),
  created             TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CHECK (num_nonnulls(target_account_id, target_event_id, target_upload_id) = 1),
  UNIQUE (author_account_id, target_account_id, target_event_id, target_upload_id)
);

COMMENT ON TABLE maevsi.report IS 'A report.';
COMMENT ON COLUMN maevsi.report.id IS E'@omit create,update\nThe report''s internal id.';
COMMENT ON COLUMN maevsi.report.author_account_id IS 'The id of the user who created the report.';
COMMENT ON COLUMN maevsi.report.reason IS 'The reason given by the reporter on why the report was created.';
COMMENT ON COLUMN maevsi.report.target_account_id IS 'The id of the account the report was created for.';
COMMENT ON COLUMN maevsi.report.target_event_id IS 'The id of the event the report was created for.';
COMMENT ON COLUMN maevsi.report.target_upload_id IS 'The id of the upload the report was created for.';
COMMENT ON COLUMN maevsi.report.created IS 'The timestamp when the report was created.';

COMMIT;
