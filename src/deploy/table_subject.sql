BEGIN;

\set role_service_vibetype_username `cat /run/secrets/postgres-role-service-vibetype-username`

CREATE TABLE vibetype_private.subject (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  key         BYTEA NOT NULL DEFAULT public.gen_random_bytes(32),
  merged_into UUID REFERENCES vibetype_private.subject(id)
);

CREATE INDEX idx_subject_merged_into ON vibetype_private.subject USING btree (merged_into);

COMMENT ON TABLE vibetype_private.subject IS 'A real-world person the system holds personal data about. Its key encrypts outbox payloads concerning that person; destroying the key permanently and irrecoverably erases that data from every past outbox message (crypto-shredding), satisfying GDPR erasure without touching Kafka''s append-only log.';
COMMENT ON COLUMN vibetype_private.subject.id IS 'The subject''s internal id.';
COMMENT ON COLUMN vibetype_private.subject.key IS 'AES-256 key material used to encrypt outbox payloads concerning this subject.';
COMMENT ON COLUMN vibetype_private.subject.merged_into IS 'When two subjects are later discovered to be the same person, points at the subject they were merged into. Always null today; reserved for future subject-merge support.';
COMMENT ON INDEX vibetype_private.idx_subject_merged_into IS 'Covers the merged_into foreign key.';

-- The service role needs to read keys to decrypt outbox payloads at send time. Deliberately not
-- granted to the grafana observability role: exposing raw key material there would defeat the
-- point of encrypting in the first place.
GRANT SELECT ON TABLE vibetype_private.subject TO :role_service_vibetype_username;

COMMIT;
