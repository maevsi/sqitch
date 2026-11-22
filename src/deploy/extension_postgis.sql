BEGIN;

-- privilege_execute_revoke would otherwise strip PUBLIC's EXECUTE from the PostGIS functions, which roles need to write geography values.
ALTER DEFAULT PRIVILEGES GRANT EXECUTE ON FUNCTIONS TO PUBLIC;

CREATE EXTENSION IF NOT EXISTS postgis;

ALTER DEFAULT PRIVILEGES REVOKE EXECUTE ON FUNCTIONS FROM PUBLIC;

COMMENT ON EXTENSION postgis IS 'Provides support for geographic objects and spatial queries.';

COMMIT;
