BEGIN;

-- PostgreSQL only inlines a STRICT SQL function whose body is strict as well,
-- which `NULLIF` is not. Without arguments `STRICT` has no effect, but it kept
-- every policy filter that is not an index condition calling this function
-- once per row.
CREATE OR REPLACE FUNCTION vibetype.invoker_account_id() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  SELECT NULLIF(current_setting('jwt.claims.sub', true), '')::UUID;
$$;

COMMIT;
