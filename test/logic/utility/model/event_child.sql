CREATE OR REPLACE FUNCTION vibetype_test.event_child_create (
  _account_id UUID,
  _event_id UUID,
  _address_name TEXT
) RETURNS UUID
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
DECLARE
  _address_id UUID;
  _app_id UUID;
  _upload_id UUID;
BEGIN
  INSERT INTO vibetype.address (name, created_by) VALUES (_address_name, _account_id) RETURNING id INTO _address_id;
  UPDATE vibetype.event SET address_id = _address_id WHERE id = _event_id;

  INSERT INTO vibetype.app (name, icon_svg, url, url_attendance, created_by)
    VALUES (_address_name, '<svg/>', 'https://example.com', 'https://example.com/attendance', _account_id) RETURNING id INTO _app_id;
  INSERT INTO vibetype.event_app (app_id, event_id, created_by) VALUES (_app_id, _event_id, _account_id);

  INSERT INTO vibetype.event_category_mapping (event_id, category_id) SELECT _event_id, id FROM vibetype.event_category WHERE name = 'category';
  INSERT INTO vibetype.event_format_mapping (event_id, format_id) SELECT _event_id, id FROM vibetype.event_format WHERE name = 'format';

  INSERT INTO vibetype.upload (created_by, size_byte) VALUES (_account_id, 1) RETURNING id INTO _upload_id;
  INSERT INTO vibetype.event_upload (event_id, upload_id) VALUES (_event_id, _upload_id);

  RETURN _address_id;
END $$;

COMMENT ON FUNCTION vibetype_test.event_child_create(UUID, UUID, TEXT) IS 'Gives an event an address and a row in each of its child tables, and returns the address id.';

GRANT EXECUTE ON FUNCTION vibetype_test.event_child_create(UUID, UUID, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_child_test (
  _test_case TEXT,
  _account_id UUID,
  _all_event_ids UUID[],
  _expected_event_ids UUID[],
  _expected_address_ids UUID[]
) RETURNS VOID AS $$
DECLARE
  _actual UUID[];
  _table TEXT;
BEGIN
  IF _account_id IS NULL THEN
    PERFORM vibetype_test.invoker_set_anonymous();
  ELSE
    PERFORM vibetype_test.invoker_set(_account_id);
  END IF;

  FOREACH _table IN ARRAY ARRAY['event_app', 'event_category_mapping', 'event_format_mapping', 'event_upload'] LOOP
    EXECUTE format('SELECT COALESCE(array_agg(event_id ORDER BY event_id), ARRAY[]::UUID[]) FROM vibetype.%I', _table) INTO _actual;

    IF _actual IS DISTINCT FROM (SELECT COALESCE(array_agg(x ORDER BY x), ARRAY[]::UUID[]) FROM unnest(_expected_event_ids) AS x) THEN
      RAISE EXCEPTION '%: % has an unexpected visibility', _test_case, _table;
    END IF;

    -- A filter by event_id must see the same rows as the unfiltered read.
    EXECUTE format('SELECT COALESCE(array_agg(event_id ORDER BY event_id), ARRAY[]::UUID[]) FROM vibetype.%I WHERE event_id = ANY ($1)', _table)
      INTO _actual USING _all_event_ids;

    IF _actual IS DISTINCT FROM (SELECT COALESCE(array_agg(x ORDER BY x), ARRAY[]::UUID[]) FROM unnest(_expected_event_ids) AS x) THEN
      RAISE EXCEPTION '%: % has an unexpected visibility when filtered by event_id', _test_case, _table;
    END IF;
  END LOOP;

  SELECT COALESCE(array_agg(id ORDER BY id), ARRAY[]::UUID[]) INTO _actual FROM vibetype.address;

  IF _actual IS DISTINCT FROM (SELECT COALESCE(array_agg(x ORDER BY x), ARRAY[]::UUID[]) FROM unnest(_expected_address_ids) AS x) THEN
    RAISE EXCEPTION '%: address has an unexpected visibility', _test_case;
  END IF;

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.event_child_test(TEXT, UUID, UUID[], UUID[], UUID[]) TO vibetype_account;
