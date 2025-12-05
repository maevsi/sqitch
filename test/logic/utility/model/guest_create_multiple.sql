CREATE OR REPLACE FUNCTION vibetype_test.guest_create_multiple_test (
  _test_case TEXT,
  _account_id UUID,
  _event_id UUID,
  _contact_ids UUID[],
  _guest_ids UUID[]
) RETURNS VOID AS $$
BEGIN
  IF _account_id IS NULL THEN
    PERFORM vibetype_test.invoker_set_anonymous();
  ELSE
    PERFORM vibetype_test.invoker_set(_account_id);
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

  PERFORM vibetype_test.invoker_set_previous();
END $$ LANGUAGE plpgsql;

GRANT EXECUTE ON FUNCTION vibetype_test.guest_create_multiple_test(TEXT, UUID, UUID, UUID[], UUID[]) TO vibetype_account;
