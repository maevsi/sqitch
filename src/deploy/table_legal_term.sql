BEGIN;

CREATE TABLE vibetype.legal_term (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  language    VARCHAR(5) NOT NULL DEFAULT 'en' CHECK (language ~ '^[a-z]{2}(_[A-Z]{2})?$'),
  term        TEXT NOT NULL CHECK (char_length(term) > 0 AND char_length(term) <= 500000),
  version     VARCHAR(20) NOT NULL CHECK (version ~ '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)$'),

  created_at  TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,

  UNIQUE (language, version)

  -- other potential columns:
  -- - content management extensions:
  --   - creator
  --   - approver
  --   - status (draft, published, active, archived)
  -- - features
  --   - published_at
  --   - summary
  --   - is_acceptance_mandatory
  --   - effective_at
  --   - revocation_policy (how it's possible to revoce a given consent)
  -- - legal specifications
  --   - jurisdiction (like "Courts of Germany" as places where legal disputes would be resolved)
  --   - law (like "GDPR")
);

COMMENT ON TABLE vibetype.legal_term IS E'@behavior -insert -update -delete\nLegal terms like privacy policies or terms of service.';
COMMENT ON COLUMN vibetype.legal_term.id IS 'Unique identifier for each legal term.';
COMMENT ON COLUMN vibetype.legal_term.language IS 'Language code in ISO 639-1 format with optional region (e.g., `en` for English, `en_GB` for British English)';
COMMENT ON COLUMN vibetype.legal_term.term IS 'Text of the legal term. Markdown is expected to be used. It must be non-empty and cannot exceed 500,000 characters.';
COMMENT ON COLUMN vibetype.legal_term.version IS 'Semantic versioning string to track changes to the legal terms (format: `X.Y.Z`).';
COMMENT ON COLUMN vibetype.legal_term.created_at IS 'Timestamp when the term was created. Set to the current time by default.';

CREATE FUNCTION vibetype.legal_term_change() RETURNS trigger
  LANGUAGE plpgsql
  AS $$
BEGIN
  RAISE EXCEPTION 'Changes to legal terms are not allowed to keep historical integrity. Publish a new version instead.';
  RETURN NULL;
END;
$$;

CREATE TRIGGER update
BEFORE UPDATE ON vibetype.legal_term
FOR EACH ROW
EXECUTE FUNCTION vibetype.legal_term_change();

CREATE TRIGGER delete
BEFORE DELETE ON vibetype.legal_term
FOR EACH ROW
EXECUTE FUNCTION vibetype.legal_term_change();

GRANT SELECT ON TABLE vibetype.legal_term TO vibetype_account, vibetype_anonymous;

ALTER TABLE vibetype.legal_term ENABLE ROW LEVEL SECURITY;

-- Make all legal terms accessible by anyone.
CREATE POLICY legal_term_select ON vibetype.legal_term FOR SELECT USING (
  TRUE
);

COMMIT;
