-- Revert maevsi:table_report_policy from pg

BEGIN;

DROP POLICY report_select ON maevsi.report;
DROP POLICY report_insert ON maevsi.report;

COMMIT;
