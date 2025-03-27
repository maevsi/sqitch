BEGIN;

CREATE TABLE vibetype.report (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  reason              TEXT NOT NULL CHECK (char_length("reason") > 0 AND char_length("reason") < 2000),
  target_account_id   UUID REFERENCES vibetype.account(id) ON DELETE CASCADE,
  target_event_id     UUID REFERENCES vibetype.event(id) ON DELETE CASCADE,
  target_upload_id    UUID REFERENCES vibetype.upload(id) ON DELETE CASCADE,

  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_by          UUID NOT NULL REFERENCES vibetype.account(id) ON DELETE CASCADE,

  CHECK (num_nonnulls(target_account_id, target_event_id, target_upload_id) = 1),
  UNIQUE (created_by, target_account_id, target_event_id, target_upload_id)
);

COMMENT ON TABLE vibetype.report IS E'@omit update,delete\nStores reports made by users on other users, events, or uploads for moderation purposes.';
COMMENT ON COLUMN vibetype.report.id IS E'@omit create\nUnique identifier for the report, generated randomly using UUIDs.';
COMMENT ON COLUMN vibetype.report.reason IS 'The reason for the report, provided by the reporting user. Must be non-empty and less than 2000 characters.';
COMMENT ON COLUMN vibetype.report.target_account_id IS 'The ID of the account being reported, if applicable.';
COMMENT ON COLUMN vibetype.report.target_event_id IS 'The ID of the event being reported, if applicable.';
COMMENT ON COLUMN vibetype.report.target_upload_id IS 'The ID of the upload being reported, if applicable.';
COMMENT ON COLUMN vibetype.report.created_at IS E'@omit create\nTimestamp of when the report was created, defaults to the current timestamp.';
COMMENT ON COLUMN vibetype.report.created_by IS 'The ID of the user who created the report.';
COMMENT ON CONSTRAINT report_reason_check ON vibetype.report IS 'Ensures the reason field contains between 1 and 2000 characters.';
COMMENT ON CONSTRAINT report_check ON vibetype.report IS 'Ensures that the report targets exactly one element (account, event, or upload).';
COMMENT ON CONSTRAINT report_created_by_target_account_id_target_event_id_target__key ON vibetype.report IS 'Ensures that the same user cannot submit multiple reports on the same element (account, event, or upload).';

COMMIT;
