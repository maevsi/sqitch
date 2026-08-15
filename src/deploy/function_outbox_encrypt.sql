BEGIN;

CREATE FUNCTION vibetype_private.outbox_encrypt(subject_id uuid, data jsonb) RETURNS bytea
    LANGUAGE sql STRICT SECURITY DEFINER
    AS $$
  WITH iv AS (
    SELECT public.gen_random_bytes(16) AS bytes
  )
  SELECT iv.bytes || public.encrypt_iv(
    convert_to(outbox_encrypt.data::text, 'UTF8'),
    (SELECT key FROM vibetype_private.subject WHERE id = outbox_encrypt.subject_id),
    iv.bytes,
    'aes'
  )
  FROM iv;
$$;

COMMENT ON FUNCTION vibetype_private.outbox_encrypt(UUID, JSONB) IS 'Encrypts data for the outbox payload under the given subject''s key, using AES-CBC with a fresh random IV prepended to the ciphertext (first 16 bytes). Destroying the subject''s key (crypto-shredding) makes every past outbox message encrypted this way permanently unrecoverable.';

COMMIT;
