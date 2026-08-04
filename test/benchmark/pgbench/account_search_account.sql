-- Account search. Only granted to vibetype_account (see
-- src/deploy/function_account_search.sql), so there's no anonymous variant.
SET ROLE vibetype_account;
SELECT set_config('jwt.claims.sub', ':account_id', false);
SELECT * FROM vibetype.account_search('benchmark');
