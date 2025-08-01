BEGIN;

DO $$
BEGIN

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.friendship_accept(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test failed: vibetype_account does not have EXECUTE privilege for vibetype.friendship_accept(UUID).';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.friendship_cancel(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test failed: vibetype_account does not have EXECUTE privilege for vibetype.friendship_cancel(UUID).';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.friendship_notify_request(UUID, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test failed: vibetype_account does not have EXECUTE privilege for vibetype.friendship_notify_request(UUID, TEXT).';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.friendship_request(UUID, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test failed: vibetype_account does not have EXECUTE privilege for vibetype.friendship_request(UUID, TEXT).';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.friendship_toggle_closeness(UUID)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test failed: vibetype_account does not have EXECUTE privilege for vibetype.friendship_toggle_closeness(UUID).';
  END IF;

END $$;

ROLLBACK;
