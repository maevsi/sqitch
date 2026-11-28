BEGIN;

-- sqitch 14 makes usernames unique regardless of capitalization, which usernames differing only in case would violate.
-- The account created first keeps its username, each later one gets the lowest free numeric suffix, like `name-2`, and can still sign in with its email address.
DO $$
DECLARE
  _account RECORD;
  _candidate TEXT;
  _suffix INTEGER;
BEGIN
  FOR _account IN
    SELECT a.id, a.username
    FROM vibetype.account a
    JOIN vibetype_private.account p ON p.id = a.id
    WHERE EXISTS (
      SELECT 1
      FROM vibetype.account o
      JOIN vibetype_private.account op ON op.id = o.id
      WHERE lower(o.username) = lower(a.username)
        AND (op.created_at, o.id) < (p.created_at, a.id)
    )
    ORDER BY p.created_at, a.id
  LOOP
    _suffix := 2;
    LOOP
      _candidate := left(_account.username, 100 - length('-' || _suffix)) || '-' || _suffix;
      EXIT WHEN NOT EXISTS (SELECT 1 FROM vibetype.account WHERE lower(username) = lower(_candidate));
      _suffix := _suffix + 1;
    END LOOP;

    UPDATE vibetype.account SET username = _candidate WHERE id = _account.id;
  END LOOP;
END $$;

COMMIT;
