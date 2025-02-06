CREATE FUNCTION maevsi.trigger_metadata_update()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  NEW.updated_by = maevsi.invoker_account_id();

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION maevsi.trigger_metadata_update() IS 'Trigger function to automatically update metadata fields `updated_at` and `updated_by` when a row is modified. Sets `updated_at` to the current timestamp and `updated_by` to the account ID of the invoker.';

GRANT EXECUTE ON FUNCTION maevsi.trigger_metadata_update() TO maevsi_account;
