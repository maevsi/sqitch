BEGIN;

\set role_service_postgraphile_username `cat /run/secrets/postgres-role-service-postgraphile-username`
\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

-- PostGraphile runs a request without a token as its connection role. Inheriting
-- the service role there made every policy granted `TO` the service role apply
-- to such requests. The membership stays for `SET ROLE` only.
GRANT :role_service_vibetype_username TO :role_service_postgraphile_username WITH INHERIT FALSE, SET TRUE;

COMMIT;
