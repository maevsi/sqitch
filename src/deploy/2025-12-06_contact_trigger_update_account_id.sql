BEGIN;

CREATE OR REPLACE FUNCTION vibetype.trigger_contact_update_account_id() RETURNS TRIGGER AS $$
  BEGIN
    IF (
      -- invoked without account id
      vibetype.invoker_account_id() IS NULL
      OR
      -- invoked with account id
      -- and
      (
        -- updating own account's contact
        OLD.account_id = vibetype.invoker_account_id()
        AND
        OLD.created_by = vibetype.invoker_account_id()
        AND
        (
          -- trying to detach from account
          NEW.account_id IS DISTINCT FROM OLD.account_id
          OR
          NEW.created_by IS DISTINCT FROM OLD.created_by
        )
      )
    ) THEN
      RAISE 'You cannot remove the association of your account''s own contact with your account.' USING ERRCODE = 'foreign_key_violation';
    END IF;

    RETURN NEW;
  END;
$$ LANGUAGE PLPGSQL STRICT SECURITY DEFINER;

COMMIT;
