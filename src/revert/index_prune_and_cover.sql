BEGIN;

DROP INDEX vibetype.idx_event_created_by_start;
DROP INDEX vibetype_private.idx_account_password_reset_verification;
DROP INDEX vibetype_private.idx_account_email_address_verification;

CREATE INDEX idx_account_block_created_by ON vibetype.account_block USING btree (created_by);
CREATE INDEX idx_account_social_network_account_id ON vibetype.account_social_network USING btree (account_id);
CREATE INDEX idx_achievement_account_id ON vibetype.achievement USING btree (account_id);
CREATE INDEX idx_contact_created_by ON vibetype.contact USING btree (created_by);
CREATE INDEX idx_device_created_by ON vibetype.device USING btree (created_by);
CREATE INDEX idx_event_app_event_id ON vibetype.event_app USING btree (event_id);
CREATE INDEX idx_event_category_mapping_event_id ON vibetype.event_category_mapping USING btree (event_id);
CREATE INDEX idx_event_created_by ON vibetype.event USING btree (created_by);
CREATE INDEX idx_event_favorite_created_by ON vibetype.event_favorite USING btree (created_by);
CREATE INDEX idx_event_format_mapping_event_id ON vibetype.event_format_mapping USING btree (event_id);
CREATE INDEX idx_event_recommendation_account_id ON vibetype.event_recommendation USING btree (account_id);
CREATE INDEX idx_friendship_a_account_id ON vibetype.friendship USING btree (a_account_id);
CREATE INDEX idx_guest_event_id ON vibetype.guest USING btree (event_id);
CREATE INDEX idx_preference_event_category_account_id ON vibetype.preference_event_category USING btree (account_id);
CREATE INDEX idx_preference_event_format_account_id ON vibetype.preference_event_format USING btree (account_id);
CREATE INDEX idx_preference_event_location_created_by ON vibetype.preference_event_location USING btree (created_by);
CREATE INDEX idx_preference_event_size_account_id ON vibetype.preference_event_size USING btree (account_id);
CREATE INDEX idx_report_created_by ON vibetype.report USING btree (created_by);
CREATE INDEX idx_event_search_vector_event_id ON vibetype_private.event_search_vector USING btree (event_id);
COMMENT ON INDEX vibetype_private.idx_event_search_vector_event_id IS 'Single-column index on event_id, required because the FK-index convention (see vibetype_test.index_on_foreign_key_check()) needs an index matching the FK''s columns exactly; the primary key''s composite index does not qualify since it also includes ts_config.';

COMMIT;
