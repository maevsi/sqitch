CREATE FUNCTION maevsi.language_iso_full_text_search(language maevsi.language)
RETURNS regconfig AS $$
BEGIN
  CASE language
    -- WHEN 'ar' THEN RETURN 'arabic';
    -- WHEN 'ca' THEN RETURN 'catalan';
    -- WHEN 'da' THEN RETURN 'danish';
    WHEN 'de' THEN RETURN 'german';
    -- WHEN 'el' THEN RETURN 'greek';
    WHEN 'en' THEN RETURN 'english';
    -- WHEN 'es' THEN RETURN 'spanish';
    -- WHEN 'eu' THEN RETURN 'basque';
    -- WHEN 'fi' THEN RETURN 'finnish';
    -- WHEN 'fr' THEN RETURN 'french';
    -- WHEN 'ga' THEN RETURN 'irish';
    -- WHEN 'hi' THEN RETURN 'hindi';
    -- WHEN 'hu' THEN RETURN 'hungarian';
    -- WHEN 'hy' THEN RETURN 'armenian';
    -- WHEN 'id' THEN RETURN 'indonesian';
    -- WHEN 'it' THEN RETURN 'italian';
    -- WHEN 'lt' THEN RETURN 'lithuanian';
    -- WHEN 'ne' THEN RETURN 'nepali';
    -- WHEN 'nl' THEN RETURN 'dutch';
    -- WHEN 'no' THEN RETURN 'norwegian';
    -- WHEN 'pt' THEN RETURN 'portuguese';
    -- WHEN 'ro' THEN RETURN 'romanian';
    -- WHEN 'ru' THEN RETURN 'russian';
    -- WHEN 'sr' THEN RETURN 'serbian';
    -- WHEN 'sv' THEN RETURN 'swedish';
    -- WHEN 'ta' THEN RETURN 'tamil';
    -- WHEN 'tr' THEN RETURN 'turkish';
    -- WHEN 'yi' THEN RETURN 'yiddish';
    ELSE RETURN 'simple';
  END CASE;
END;
$$ LANGUAGE PLPGSQL STABLE SECURITY DEFINER;

COMMENT ON FUNCTION maevsi.language_iso_full_text_search(maevsi.language) IS 'Maps an ISO language code to the corresponding PostgreSQL text search configuration. This function returns the appropriate text search configuration for supported languages, such as "german" for "de" and "english" for "en". If the language code is not explicitly handled, the function defaults to the "simple" configuration, which is a basic tokenizer that does not perform stemming or handle stop words. This ensures that full-text search can work with a wide range of languages even if specific optimizations are not available for some.';

GRANT EXECUTE ON FUNCTION maevsi.language_iso_full_text_search(maevsi.language) TO maevsi_anonymous, maevsi_account;
