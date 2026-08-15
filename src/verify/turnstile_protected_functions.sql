BEGIN;

DO $$
BEGIN
  IF obj_description('vibetype.jwt_create(text, text)'::regprocedure, 'pg_proc') NOT LIKE '%@turnstileProtected%' THEN
    RAISE EXCEPTION 'vibetype.jwt_create is missing the @turnstileProtected tag';
  END IF;

  IF obj_description('vibetype.account_registration(uuid, date, uuid, text, text)'::regprocedure, 'pg_proc') NOT LIKE '%@turnstileProtected%' THEN
    RAISE EXCEPTION 'vibetype.account_registration is missing the @turnstileProtected tag';
  END IF;
END $$;

ROLLBACK;
