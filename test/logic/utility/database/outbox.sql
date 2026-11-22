-- Outbox rows are deleted right after their insertion, so tests keep them by disabling that trigger
-- for the rest of their transaction.
CREATE OR REPLACE FUNCTION vibetype_test.outbox_capture()
RETURNS VOID
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
  ALTER TABLE vibetype_private.outbox DISABLE TRIGGER delete;
END $$;

GRANT EXECUTE ON FUNCTION vibetype_test.outbox_capture() TO vibetype_account, vibetype_anonymous;


CREATE OR REPLACE FUNCTION vibetype_test.outbox_payload(
  _type TEXT,
  _aggregate_id UUID
)
RETURNS JSONB
    LANGUAGE sql STABLE STRICT SECURITY DEFINER
    AS $$
  SELECT payload
  FROM vibetype_private.outbox
  WHERE type = _type AND aggregate_id = _aggregate_id;
$$;

GRANT EXECUTE ON FUNCTION vibetype_test.outbox_payload(TEXT, UUID) TO vibetype_account, vibetype_anonymous;
