BEGIN;

DROP FUNCTION vibetype.account_search(TEXT);

DROP INDEX vibetype.idx_account_username_like;

DROP EXTENSION pg_trgm;

COMMIT;