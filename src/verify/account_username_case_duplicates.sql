BEGIN;

SELECT 1/(1 - count(*)) FROM (SELECT 1 FROM vibetype.account GROUP BY lower(username) HAVING count(*) > 1 LIMIT 1) t;

ROLLBACK;
