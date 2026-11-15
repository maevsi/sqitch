BEGIN;

REVOKE UPDATE (description, imprint_url) ON TABLE vibetype.account FROM vibetype_account;
GRANT UPDATE ON TABLE vibetype.account TO vibetype_account;

REVOKE UPDATE (checked_out) ON TABLE vibetype.attendance FROM vibetype_account, vibetype_anonymous;
GRANT UPDATE ON TABLE vibetype.attendance TO vibetype_account, vibetype_anonymous;

REVOKE INSERT (a_account_id, b_account_id, created_by), UPDATE (status) ON TABLE vibetype.friendship FROM vibetype_account;
GRANT INSERT, UPDATE ON TABLE vibetype.friendship TO vibetype_account;

REVOKE INSERT (created_by, name, size_byte), UPDATE (name) ON TABLE vibetype.upload FROM vibetype_account;
GRANT INSERT, UPDATE ON TABLE vibetype.upload TO vibetype_account;

COMMIT;
