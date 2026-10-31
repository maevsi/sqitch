BEGIN;

DO $$
BEGIN
  -- without a default acl entry, postgres falls back to granting execute to public
  ASSERT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_default_acl
    WHERE defaclrole = current_user::regrole
      AND defaclnamespace = 0
      AND defaclobjtype = 'f'
  );
  ASSERT NOT EXISTS (
    SELECT 1
    FROM pg_catalog.pg_default_acl, pg_catalog.aclexplode(defaclacl) AS acl
    WHERE defaclrole = current_user::regrole
      AND defaclnamespace = 0
      AND defaclobjtype = 'f'
      AND acl.grantee = 0 -- public
      AND acl.privilege_type = 'EXECUTE'
  );
END $$;

ROLLBACK;
