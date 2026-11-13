BEGIN;

-- `@behavior -insert` and `@behavior -update` only hide a column from GraphQL.
-- These tables granted writes on every column, leaving the columns below
-- protected by smart tags alone.

REVOKE UPDATE ON TABLE vibetype.account FROM vibetype_account;
GRANT UPDATE (description, imprint_url) ON TABLE vibetype.account TO vibetype_account;

REVOKE UPDATE ON TABLE vibetype.attendance FROM vibetype_account, vibetype_anonymous;
GRANT UPDATE (checked_out) ON TABLE vibetype.attendance TO vibetype_account, vibetype_anonymous;

-- A friendship is requested by one participant and accepted by the other, its participants never change.
REVOKE INSERT, UPDATE ON TABLE vibetype.friendship FROM vibetype_account;
GRANT INSERT (a_account_id, b_account_id, created_by) ON TABLE vibetype.friendship TO vibetype_account;
GRANT UPDATE (status) ON TABLE vibetype.friendship TO vibetype_account;

-- The storage key and type of an upload are set by the service.
REVOKE INSERT, UPDATE ON TABLE vibetype.upload FROM vibetype_account;
GRANT INSERT (created_by, name, size_byte) ON TABLE vibetype.upload TO vibetype_account;
GRANT UPDATE (name) ON TABLE vibetype.upload TO vibetype_account;

COMMIT;
