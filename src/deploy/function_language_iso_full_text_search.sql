CREATE FUNCTION vibetype.language_iso_full_text_search(language vibetype.language) RETURNS regconfig
    LANGUAGE sql STABLE
    AS $$
  SELECT
    CASE language
      -- WHEN 'ar' THEN 'arabic'
      -- WHEN 'ca' THEN 'catalan'
      -- WHEN 'da' THEN 'danish'
      WHEN 'de' THEN 'german'
      -- WHEN 'el' THEN 'greek'
      WHEN 'en' THEN 'english'
      -- WHEN 'es' THEN 'spanish'
      -- WHEN 'eu' THEN 'basque'
      -- WHEN 'fi' THEN 'finnish'
      -- WHEN 'fr' THEN 'french'
      -- WHEN 'ga' THEN 'irish'
      -- WHEN 'hi' THEN 'hindi'
      -- WHEN 'hu' THEN 'hungarian'
      -- WHEN 'hy' THEN 'armenian'
      -- WHEN 'id' THEN 'indonesian'
      -- WHEN 'it' THEN 'italian'
      -- WHEN 'lt' THEN 'lithuanian'
      -- WHEN 'ne' THEN 'nepali'
      -- WHEN 'nl' THEN 'dutch'
      -- WHEN 'no' THEN 'norwegian'
      -- WHEN 'pt' THEN 'portuguese'
      -- WHEN 'ro' THEN 'romanian'
      -- WHEN 'ru' THEN 'russian'
      -- WHEN 'sr' THEN 'serbian'
      -- WHEN 'sv' THEN 'swedish'
      -- WHEN 'ta' THEN 'tamil'
      -- WHEN 'tr' THEN 'turkish'
      -- WHEN 'yi' THEN 'yiddish'
      ELSE 'simple'
    END::regconfig;
$$;

COMMENT ON FUNCTION vibetype.language_iso_full_text_search(vibetype.language) IS 'Maps an ISO language code to the corresponding PostgreSQL text search configuration. This function returns the appropriate text search configuration for supported languages, such as "german" for "de" and "english" for "en". If the language code is not explicitly handled, the function defaults to the "simple" configuration, which is a basic tokenizer that does not perform stemming or handle stop words. This ensures that full-text search can work with a wide range of languages even if specific optimizations are not available for some.';

GRANT EXECUTE ON FUNCTION vibetype.language_iso_full_text_search(vibetype.language) TO vibetype_anonymous, vibetype_account;
