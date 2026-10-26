BEGIN;

-- Needs SECURITY DEFINER as querying vibetype.upload under RLS recurses into vibetype.profile_picture via `upload_select`.
CREATE FUNCTION vibetype_private.upload_is_own(upload_id UUID) RETURNS boolean
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT EXISTS (
    SELECT 1
    FROM vibetype.upload u
    WHERE u.id = upload_is_own.upload_id
      AND u.created_by = vibetype.invoker_account_id()
  );
$$;

COMMENT ON FUNCTION vibetype_private.upload_is_own(UUID) IS 'Returns whether the given upload was created by the invoker.';

GRANT EXECUTE ON FUNCTION vibetype_private.upload_is_own(UUID) TO vibetype_account;

-- A profile picture must reference one of the invoker's own uploads.
CREATE POLICY profile_picture_upload_own ON vibetype.profile_picture AS RESTRICTIVE FOR ALL
USING (
  TRUE
)
WITH CHECK (
  vibetype_private.upload_is_own(profile_picture.upload_id)
);

COMMIT;
