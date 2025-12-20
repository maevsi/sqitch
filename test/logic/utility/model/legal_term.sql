CREATE FUNCTION vibetype_test.legal_term_select_by_singleton ()
RETURNS UUID
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
DECLARE
  _id UUID;
  _verification UUID;
BEGIN
  SELECT id INTO _id FROM vibetype.legal_term LIMIT 1;

  IF (_id IS NULL) THEN
    INSERT INTO vibetype.legal_term (term, version) VALUES ('Be excellent to each other', '0.0.0')
      RETURNING id INTO _id;
  END IF;

  RETURN _id;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.legal_term_select_by_singleton() TO vibetype_account, vibetype_anonymous;
