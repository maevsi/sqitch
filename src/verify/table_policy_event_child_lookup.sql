BEGIN;

DO $$
BEGIN
  IF (
    SELECT count(*)
    FROM pg_policies
    WHERE schemaname = 'vibetype'
      AND policyname IN ('address_all', 'event_app_select', 'event_category_mapping_select', 'event_format_mapping_select', 'event_upload_select')
      AND qual LIKE '%OFFSET 0%'
  ) <> 5 THEN
    RAISE EXCEPTION 'A policy is missing.';
  END IF;
END $$;

ROLLBACK;
