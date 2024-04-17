-- Deploy maevsi:table_report to pg

BEGIN;

CREATE TABLE maevsi.report (
    id              UUID PRIMARY KEY NOT NULL DEFAULT gen_random_uuid(),
    reporter_id     UUID NOT NULL REFERENCES maevsi.account(id),
    reason          TEXT NOT NULL,
    event_id        UUID REFERENCES maevsi.event(id),
    upload_id       UUID REFERENCES maevsi.upload(id),
    user_id         UUID REFERENCES maevsi.account(id),
    CHECK (num_nonnulls(event_id, upload_id, user_id) = 1),
    UNIQUE (reporter_id, event_id, upload_id, user_id)
);

COMMENT ON TABLE maevsi.report IS 'A report.';
COMMENT ON COLUMN maevsi.report.id IS 'The report''s internal id.';
COMMENT ON COLUMN maevsi.report.reporter_id IS 'The id of the user that created the report.';
COMMENT ON COLUMN maevsi.report.reason IS 'The reason why the report was created.';
COMMENT ON COLUMN maevsi.report.event_id IS 'The id of an event the report was created for.';
COMMENT ON COLUMN maevsi.report.upload_id IS 'The id of an upload the report was created for.';
COMMENT ON COLUMN maevsi.report.user_id IS 'The id of a user the report was created for.';

COMMIT;
