BEGIN;

DO $$
DECLARE
  _subject_id UUID;
  _key BYTEA;
  _ciphertext BYTEA;
  _iv BYTEA;
  _decrypted TEXT;
BEGIN
  INSERT INTO vibetype_private.subject DEFAULT VALUES RETURNING id, key INTO _subject_id, _key;

  _ciphertext := vibetype_private.outbox_encrypt(_subject_id, '{"foo": "bar"}'::jsonb);
  _iv := substring(_ciphertext FROM 1 FOR 16);
  _decrypted := convert_from(public.decrypt_iv(substring(_ciphertext FROM 17), _key, _iv, 'aes'), 'UTF8');

  IF _decrypted != '{"foo": "bar"}' THEN
    RAISE EXCEPTION 'outbox_encrypt/decrypt_iv round trip failed: got %', _decrypted;
  END IF;
END $$;

ROLLBACK;
