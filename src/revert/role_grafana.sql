-- Revert maevsi:role_grafana from pg

\connect grafana

BEGIN;

DROP OWNED BY grafana;
DROP ROLE grafana;

COMMIT;
