-- Revert maevsi:table_report_policy from pg

BEGIN;

DROP POLICY report_insert;

COMMIT;
