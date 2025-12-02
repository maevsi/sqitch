CREATE OR REPLACE FUNCTION vibetype_test.event_category_create (
  _category TEXT
) RETURNS VOID AS $$
BEGIN
  INSERT INTO vibetype.event_category(name) VALUES (_category);
END $$ LANGUAGE plpgsql STRICT SECURITY DEFINER;

GRANT EXECUTE ON FUNCTION vibetype_test.event_category_create(TEXT) TO vibetype_account;
