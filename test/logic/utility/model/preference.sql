-- Runs as the invoker (not SECURITY DEFINER) so that row level security applies.
CREATE OR REPLACE FUNCTION vibetype_test.preference_count()
RETURNS INTEGER[] AS $$
  SELECT ARRAY[
    (SELECT COUNT(1) FROM vibetype.preference_event_category),
    (SELECT COUNT(1) FROM vibetype.preference_event_format),
    (SELECT COUNT(1) FROM vibetype.preference_event_location),
    (SELECT COUNT(1) FROM vibetype.preference_event_size)
  ]::INTEGER[];
$$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION vibetype_test.preference_count() IS 'Returns the number of category, format, location and size preferences visible to the invoker, in that order.';

GRANT EXECUTE ON FUNCTION vibetype_test.preference_count() TO vibetype_account;


-- Runs as the invoker (not SECURITY DEFINER) so that row level security applies.
CREATE OR REPLACE FUNCTION vibetype_test.preference_create(
  _account_id UUID,
  _category TEXT,
  _format TEXT
)
RETURNS VOID AS $$
BEGIN
  INSERT INTO vibetype.preference_event_category (account_id, category_id)
    SELECT _account_id, id FROM vibetype.event_category WHERE name = _category;
  INSERT INTO vibetype.preference_event_format (account_id, format_id)
    SELECT _account_id, id FROM vibetype.event_format WHERE name = _format;
  INSERT INTO vibetype.preference_event_location (created_by, location, radius)
    VALUES (_account_id, ST_Point(9.476, 51.304, 4326), 50000); -- Somewhere in Kassel
  INSERT INTO vibetype.preference_event_size (account_id, event_size)
    VALUES (_account_id, 'small');
END $$ LANGUAGE plpgsql STRICT;

COMMENT ON FUNCTION vibetype_test.preference_create(UUID, TEXT, TEXT) IS 'Inserts one category, format, location and size preference for the given account as the invoker.';

GRANT EXECUTE ON FUNCTION vibetype_test.preference_create(UUID, TEXT, TEXT) TO vibetype_account;
