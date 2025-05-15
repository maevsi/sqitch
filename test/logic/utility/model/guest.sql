CREATE OR REPLACE FUNCTION vibetype_test.guest_create (
  _created_by UUID,
  _event_id UUID,
  _contact_id UUID
) RETURNS UUID AS $$
DECLARE
  _id UUID;
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _created_by || '''';

  INSERT INTO vibetype.guest(contact_id, event_id)
  VALUES (_contact_id, _event_id)
  RETURNING id INTO _id;

  SET LOCAL ROLE NONE;

  RETURN _id;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_create(UUID, UUID, UUID) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.guest_create_multiple_test (
  _test_case TEXT,
  _account_id UUID,
  _event_id UUID,
  _contact_ids UUID[],
  _guest_ids UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    SET LOCAL ROLE = 'vibetype_anonymous';
    SET LOCAL jwt.claims.account_id = '';
  ELSE
    SET LOCAL ROLE = 'vibetype_account';
    EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';
  END IF;

  IF EXISTS (
      SELECT id FROM vibetype.guest WHERE event_id = _event_id AND contact_id = ANY(_contact_ids)
        EXCEPT
      SELECT * FROM unnest(_guest_ids)
     ) THEN
    RAISE EXCEPTION '%: some guest should not appear in table guest', _test_case;
  END IF;

  IF EXISTS (
      SELECT * FROM unnest(_guest_ids)
        EXCEPT
      SELECT id FROM vibetype.guest WHERE event_id = _event_id AND contact_id = ANY(_contact_ids)
    ) THEN
    RAISE EXCEPTION '%: some guest is missing in table guest', _test_case;
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_create_multiple_test(TEXT, UUID, UUID, UUID[], UUID[]) TO vibetype_account;


CREATE OR REPLACE FUNCTION vibetype_test.guest_test (
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

  IF EXISTS (SELECT id FROM vibetype.guest EXCEPT SELECT * FROM unnest(_expected_result)) THEN
    RAISE EXCEPTION '%: some guest should not appear in the query result', _test_case;
  END IF;

  IF EXISTS (SELECT * FROM unnest(_expected_result) EXCEPT SELECT id FROM vibetype.guest) THEN
    RAISE EXCEPTION '%: some guest is missing in the query result', _test_case;
  END IF;

  SET LOCAL ROLE NONE;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_test(TEXT, UUID, UUID[]) TO vibetype_account;


-- returns all guest ids that represent invitations received by the given account
CREATE OR REPLACE FUNCTION vibetype_test.guest_claim_from_account_guest (
  _account_id UUID
)
RETURNS UUID[] AS $$
DECLARE
  _guest vibetype.guest;
  _result UUID[] := ARRAY[]::UUID[];
  _text TEXT := '';
BEGIN
  SET LOCAL ROLE = 'vibetype_account';
  EXECUTE 'SET LOCAL jwt.claims.account_id = ''' || _account_id || '''';

  -- -- reads all guest ids that represent invitations received by the given account,
  -- -- sets jwt.claims.guests to a string representation of these guests
  -- -- and returns an array of these guests.

  FOR _guest IN
    SELECT g.id
    FROM vibetype.guest g JOIN vibetype.contact c
      ON g.contact_id = c.id
    WHERE c.account_id = _account_id
  LOOP
    _text := _text || ',"' || _guest.id || '"';
    _result := array_append(_result, _guest.id);
  END LOOP;

  IF LENGTH(_text) > 0 THEN
    _text := SUBSTR(_text, 2);
  END IF;

  EXECUTE 'SET LOCAL jwt.claims.guests = ''[' || _text || ']''';

  SET LOCAL ROLE NONE;

  RETURN _result;
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_claim_from_account_guest(UUID) TO vibetype_account;
