BEGIN;

DROP POLICY report_select ON vibetype.report;
DROP POLICY report_insert ON vibetype.report;

COMMIT;
