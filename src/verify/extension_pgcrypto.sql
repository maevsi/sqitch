BEGIN;

SELECT 1/count(*) FROM pg_extension WHERE extname = 'pgcrypto';
SELECT has_function_privilege('crypt(text, text)', 'EXECUTE');
SELECT has_function_privilege('gen_salt(text)', 'EXECUTE');

ROLLBACK;
