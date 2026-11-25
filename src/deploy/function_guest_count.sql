BEGIN;

CREATE FUNCTION vibetype.guest_count(event_id uuid) RETURNS integer
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  SELECT COALESCE(SUM(1 + companion_count), 0)::INTEGER FROM vibetype.guest WHERE guest.event_id = guest_count.event_id;
$$;

COMMENT ON FUNCTION vibetype.guest_count(UUID) IS 'Returns the number of seats taken for an event: each guest plus their approved companions.';

GRANT EXECUTE ON FUNCTION vibetype.guest_count(UUID) TO vibetype_account, vibetype_anonymous;

COMMIT;
