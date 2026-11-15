BEGIN;

DROP INDEX vibetype.idx_account_block_created_by;
DROP INDEX vibetype.idx_account_social_network_account_id;
DROP INDEX vibetype.idx_achievement_account_id;
DROP INDEX vibetype.idx_contact_created_by;
DROP INDEX vibetype.idx_device_created_by;
DROP INDEX vibetype.idx_event_app_event_id;
DROP INDEX vibetype.idx_event_category_mapping_event_id;
DROP INDEX vibetype.idx_event_created_by;
DROP INDEX vibetype.idx_event_favorite_created_by;
DROP INDEX vibetype.idx_event_format_mapping_event_id;
DROP INDEX vibetype.idx_event_recommendation_account_id;
DROP INDEX vibetype.idx_friendship_a_account_id;
DROP INDEX vibetype.idx_guest_event_id;
DROP INDEX vibetype.idx_preference_event_category_account_id;
DROP INDEX vibetype.idx_preference_event_format_account_id;
DROP INDEX vibetype.idx_preference_event_location_created_by;
DROP INDEX vibetype.idx_preference_event_size_account_id;
DROP INDEX vibetype.idx_report_created_by;
DROP INDEX vibetype_private.idx_event_search_vector_event_id;

CREATE UNIQUE INDEX idx_account_email_address_verification ON vibetype_private.account (email_address_verification) WHERE email_address_verification IS NOT NULL;
COMMENT ON INDEX vibetype_private.idx_account_email_address_verification IS 'Unique partial index serving the lookup by email address verification code.';

CREATE UNIQUE INDEX idx_account_password_reset_verification ON vibetype_private.account (password_reset_verification) WHERE password_reset_verification IS NOT NULL;
COMMENT ON INDEX vibetype_private.idx_account_password_reset_verification IS 'Unique partial index serving the lookup by password reset code.';

CREATE INDEX idx_event_created_by_start ON vibetype.event (created_by, start);
COMMENT ON INDEX vibetype.idx_event_created_by_start IS 'B-Tree index serving the events of a creator ordered by start.';

COMMIT;
