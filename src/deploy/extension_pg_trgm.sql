BEGIN;

CREATE EXTENSION pg_trgm;

COMMENT ON EXTENSION pg_trgm IS 'Provides support for similarity of text using trigram matching, also used for speeding up LIKE queries.';

COMMIT;
