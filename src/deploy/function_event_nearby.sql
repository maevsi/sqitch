BEGIN;

-- Lives in the vibetype schema so vibetype_account can call it with a plain EXECUTE grant; @behavior -* keeps it out of the GraphQL schema.
-- SECURITY DEFINER: the spatial predicate on the address location runs as the owner, so the non-leakproof row level security predicates are not applied before it and idx_address_location becomes usable.
-- SECURITY: only public events are returned, on purpose.
-- This function bypasses row level security and can be called directly, so returning ids or distances of private or unpublished events would let any caller triangulate where such an event, for example a party at someone's home, takes place.
CREATE FUNCTION vibetype.event_nearby_match(latitude DOUBLE PRECISION, longitude DOUBLE PRECISION, radius DOUBLE PRECISION) RETURNS TABLE(event_id UUID, distance DOUBLE PRECISION)
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    SET search_path = pg_catalog, public, pg_temp
    AS $$
  WITH _origin AS MATERIALIZED (
    SELECT ST_Point(event_nearby_match.longitude, event_nearby_match.latitude, 4326)::geography AS location
  )
  SELECT
    e.id,
    ST_Distance(a.location, o.location)
  FROM _origin o
  JOIN vibetype.address a
    ON ST_DWithin(a.location, o.location, event_nearby_match.radius)
  JOIN vibetype.event e
    ON e.address_id = a.id
  WHERE
    e.visibility = 'public'
    AND e.published_at <= CURRENT_TIMESTAMP
    AND NOT e.is_archived
    AND e.is_in_person;
$$;

COMMENT ON FUNCTION vibetype.event_nearby_match(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) IS E'@behavior -*\nReturns ids of public, published (not draft or scheduled), non-archived, in-person events located within the given radius in meters around the given coordinates, with their distance in meters.';

REVOKE ALL ON FUNCTION vibetype.event_nearby_match(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION vibetype.event_nearby_match(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION) TO vibetype_account;

CREATE FUNCTION vibetype.event_nearby(latitude DOUBLE PRECISION, longitude DOUBLE PRECISION, radius DOUBLE PRECISION, include_ended BOOLEAN DEFAULT false) RETURNS SETOF vibetype.event
    LANGUAGE sql STABLE
    AS $$
  SELECT e.*
  FROM vibetype.event_nearby_match(event_nearby.latitude, event_nearby.longitude, event_nearby.radius) m
  JOIN vibetype.event e ON e.id = m.event_id
  WHERE
    COALESCE(event_nearby.include_ended, false)
    OR e.effective_end >= now()
  ORDER BY
    m.distance,
    e.id;
$$;

COMMENT ON FUNCTION vibetype.event_nearby(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN) IS 'Lists public, published (not draft or scheduled), non-archived in-person events within the given radius in meters around the given coordinates, nearest first. Events that have ended are left out unless `include_ended` is true. Following RFC 5545, an event without an end ends at its start. Ordering is fully deterministic, so paginate through results via the GraphQL connection arguments rather than assuming a fixed result size.';

GRANT EXECUTE ON FUNCTION vibetype.event_nearby(DOUBLE PRECISION, DOUBLE PRECISION, DOUBLE PRECISION, BOOLEAN) TO vibetype_account;

COMMIT;
