BEGIN;

CREATE TABLE vibetype_private.jwt (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),

  expiry            timestamp with time zone GENERATED ALWAYS AS (to_timestamp(((token).exp)::double precision)) STORED NOT NULL,
  subject           uuid GENERATED ALWAYS AS ((token).sub) STORED REFERENCES vibetype.account(id) ON DELETE CASCADE,
  token             vibetype.jwt NOT NULL UNIQUE,

  created_at        timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
  updated_at        timestamp with time zone,
  updated_by        uuid REFERENCES vibetype.account(id) ON DELETE SET NULL
);

CREATE INDEX idx_jwt_subject ON vibetype_private.jwt USING btree (subject);
CREATE INDEX idx_jwt_updated_by ON vibetype_private.jwt USING btree (updated_by);

COMMENT ON TABLE vibetype_private.jwt IS 'Stored JWT and related metadata used for authentication and sessions.';
COMMENT ON COLUMN vibetype_private.jwt.id IS 'Unique token identifier (jti) used to reference this JWT.';
COMMENT ON COLUMN vibetype_private.jwt.expiry IS 'When this token expires (UTC).';
COMMENT ON COLUMN vibetype_private.jwt.subject IS 'Account ID (UUID) this token belongs to.';
COMMENT ON COLUMN vibetype_private.jwt.token IS 'The full JWT payload (claims such as attendances, jti, sub, username, exp, guests, role).';
COMMENT ON COLUMN vibetype_private.jwt.created_at IS 'Timestamp when this token record was created.';
COMMENT ON COLUMN vibetype_private.jwt.updated_at IS 'Timestamp when this token record was last updated.';
COMMENT ON COLUMN vibetype_private.jwt.updated_by IS 'Account ID of the user who last updated this token.';
COMMENT ON INDEX vibetype_private.idx_jwt_subject IS 'B-Tree index to optimize lookups by subject (account ID).';
COMMENT ON INDEX vibetype_private.idx_jwt_updated_by IS 'B-Tree index to optimize lookups by updater (account ID of last updater).';

CREATE TRIGGER update
  BEFORE
    UPDATE
  ON vibetype_private.jwt
  FOR EACH ROW
  EXECUTE FUNCTION vibetype.trigger_metadata_update();

COMMIT;
