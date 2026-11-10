BEGIN;

CREATE OR REPLACE FUNCTION vibetype.invoker_account_id() RETURNS uuid
    LANGUAGE sql STABLE STRICT
    AS $$
  SELECT NULLIF(current_setting('jwt.claims.sub', true), '')::UUID;
$$;

COMMIT;
