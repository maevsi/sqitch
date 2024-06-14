-- Revert maevsi:table_report from pg

BEGIN;

DROP TABLE maevsi.report;

COMMIT;
