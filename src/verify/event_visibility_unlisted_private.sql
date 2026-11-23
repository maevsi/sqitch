BEGIN;

SELECT 1/(1 - count(*)) FROM (SELECT 1 FROM vibetype.event WHERE visibility = 'unlisted' LIMIT 1) t;

ROLLBACK;
