CREATE FUNCTION vibetype.trigger_metadata_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  NEW.updated_by = vibetype.invoker_account_id();

  RETURN NEW;
END;
$$;
COMMENT ON FUNCTION vibetype.trigger_metadata_update() IS 'Trigger function to automatically update metadata fields `updated_at` and `updated_by` when a row is modified. Sets `updated_at` to the current timestamp and `updated_by` to the account ID of the invoker.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_metadata_update() TO vibetype_account;
