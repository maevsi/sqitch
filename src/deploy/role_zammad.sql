BEGIN;

\set role_service_zammad_password `cat /run/secrets/postgres-role-service-zammad-password`
\set role_service_zammad_username `cat /run/secrets/postgres-role-service-zammad-username`

DROP ROLE IF EXISTS :"role_service_zammad_username";
CREATE ROLE :"role_service_zammad_username" LOGIN PASSWORD :'role_service_zammad_password';

COMMIT;
