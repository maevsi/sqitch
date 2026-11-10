CREATE OR REPLACE FUNCTION vibetype_test.event_format_create (
  _format TEXT
) RETURNS VOID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
BEGIN
  INSERT INTO vibetype.event_format(name) VALUES (_format);
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.event_format_create(TEXT) TO vibetype_account;
