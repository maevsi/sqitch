BEGIN;

-- Addresses of accessible events stay readable through `address_all`, but only their creator may modify them.
CREATE POLICY address_update_creator ON vibetype.address AS RESTRICTIVE FOR UPDATE
USING (
  address.created_by = vibetype.invoker_account_id()
);

CREATE POLICY address_delete_creator ON vibetype.address AS RESTRICTIVE FOR DELETE
USING (
  address.created_by = vibetype.invoker_account_id()
);

COMMIT;
