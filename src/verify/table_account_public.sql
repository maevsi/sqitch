BEGIN;

SELECT id,
       description,
       imprint,
       username
FROM vibetype.account WHERE FALSE;

ROLLBACK;
