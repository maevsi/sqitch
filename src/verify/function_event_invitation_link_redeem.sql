BEGIN;

DO $$
BEGIN
  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_account', 'vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_account does not have EXECUTE privilege on event_invitation_link_redeem';
  END IF;

  IF NOT (SELECT pg_catalog.has_function_privilege('vibetype_anonymous', 'vibetype.event_invitation_link_redeem(UUID, TEXT, TEXT)', 'EXECUTE')) THEN
    RAISE EXCEPTION 'Test privileges failed: vibetype_anonymous does not have EXECUTE privilege on event_invitation_link_redeem';
  END IF;
END $$;

ROLLBACK;
