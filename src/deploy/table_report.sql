BEGIN;

CREATE TABLE maevsi.report (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at          TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  author_account_id   UUID NOT NULL REFERENCES maevsi.account(id),
  reason              TEXT NOT NULL CHECK (char_length("reason") > 0 AND char_length("reason") < 2000),
  target_account_id   UUID REFERENCES maevsi.account(id),
  target_event_id     UUID REFERENCES maevsi.event(id),
  target_upload_id    UUID REFERENCES maevsi.upload(id),

  CHECK (num_nonnulls(target_account_id, target_event_id, target_upload_id) = 1),
  UNIQUE (author_account_id, target_account_id, target_event_id, target_upload_id)
);

COMMENT ON TABLE maevsi.report IS E'@omit update,delete\nStores reports made by users on other users, events, or uploads for moderation purposes.';
COMMENT ON COLUMN maevsi.report.id IS E'@omit create\nUnique identifier for the report, generated randomly using UUIDs.';
COMMENT ON COLUMN maevsi.report.created_at IS E'@omit create\nTimestamp of when the report was created, defaults to the current timestamp.';
COMMENT ON COLUMN maevsi.report.author_account_id IS 'The ID of the user who created the report.';
COMMENT ON COLUMN maevsi.report.reason IS 'The reason for the report, provided by the reporting user. Must be non-empty and less than 2000 characters.';
COMMENT ON COLUMN maevsi.report.target_account_id IS 'The ID of the account being reported, if applicable.';
COMMENT ON COLUMN maevsi.report.target_event_id IS 'The ID of the event being reported, if applicable.';
COMMENT ON COLUMN maevsi.report.target_upload_id IS 'The ID of the upload being reported, if applicable.';
COMMENT ON CONSTRAINT report_reason_check ON maevsi.report IS 'Ensures the reason field contains between 1 and 2000 characters.';
COMMENT ON CONSTRAINT report_check ON maevsi.report IS 'Ensures that the report targets exactly one element (account, event, or upload).';
COMMENT ON CONSTRAINT report_author_account_id_target_account_id_target_event_id__key ON maevsi.report IS 'Ensures that the same user cannot submit multiple reports on the same element (account, event, or upload).';

COMMIT;
