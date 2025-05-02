CREATE OR REPLACE FUNCTION vibetype_test.event_category_mapping_create (
  _created_by UUID,
  _event_id UUID,
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.event_category_mapping(event_id, category_id)
  VALUES (_event_id, (SELECT id FROM vibetype.event_category WHERE name = _category));

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.event_category_mapping_create(UUID, UUID, TEXT) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.event_category_mapping_test (
  _test_case TEXT,
  _account_id UUID,
  _expected_result UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL ROLE = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL ROLE = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (SELECT event_id FROM vibetype.event_category_mapping EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION '%: some event_category_mappings should not appear in the query result', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT event_id FROM vibetype.event_category_mapping) THEN
    RAISE EXCEPTION '%: some event_category_mappings is missing in the query result', _test_case;
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.event_category_mapping_test(TEXT, UUID, UUID[]) TO vibetype_account;
