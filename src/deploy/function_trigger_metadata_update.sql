CREATE FUNCTION vibetype.trigger_metadata_update() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;

  BEGIN
    NEW.updated_by = vibetype.invoker_account_id();
  EXCEPTION
    WHEN undefined_column THEN
      NULL;
  END;

  RETURN NEW;
END;
$$;
COMMENT ON FUNCTION vibetype.trigger_metadata_update() IS 'Trigger function to automatically update metadata fields when a row is modified. Always sets `updated_at` to the current timestamp. Sets `updated_by` to the invoker account ID if the column exists on the table.';
GRANT EXECUTE ON FUNCTION vibetype.trigger_metadata_update() TO vibetype_account;
