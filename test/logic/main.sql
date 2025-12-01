\echo TEST_DIRECTORY = :TEST_DIRECTORY
\cd :TEST_DIRECTORY
\! pwd
\set USER_INITIAL :USER

\echo ==========================================================
\echo connected as :USER
\echo create schema vibetype_test, test functions and run tests
\echo ==========================================================

DROP SCHEMA IF EXISTS vibetype_test CASCADE;

CREATE SCHEMA vibetype_test;
GRANT USAGE ON SCHEMA vibetype_test TO vibetype_anonymous, vibetype_account;

\i utility/database/index.sql
\i utility/database/invoker.sql
\i utility/database/uuid.sql
\i utility/model/account_block.sql
\i utility/model/account_registration.sql
\i utility/model/account.sql
\i utility/model/contact.sql
\i utility/model/event_category_mapping.sql
\i utility/model/event_category.sql
\i utility/model/event.sql
\i utility/model/friendship.sql
\i utility/model/guest.sql
\i utility/model/legal_term.sql

\i scenario/database/account_block_ids.sql
\i scenario/database/audit_log.sql
\i scenario/database/events_invited.sql
\i scenario/database/index_missing.sql
\i scenario/database/index.sql

\echo ==========================================================
\echo connect as user postgraphile and run tests
\echo ==========================================================

\c - postgraphile

\i scenario/model/account/location.sql
\i scenario/model/account/policy.sql
\i scenario/model/event/location.sql
\i scenario/model/event/policy.sql
\i scenario/model/account_block_accounts.sql
\i scenario/model/account_registration.sql
\i scenario/model/account_search.sql
\i scenario/model/account_social_network.sql
\i scenario/model/authenticate.sql
\i scenario/model/contact.sql
\i scenario/model/event_category_mapping.sql
\i scenario/model/event_favorite.sql
\i scenario/model/friendship.sql
\i scenario/model/guest_claim_array.sql
\i scenario/model/guest_create_multiple.sql
\i scenario/model/guest.sql
-- \i scenario/model/invite.sql -- TODO: remove comment when PR "feat(notification)!: inherit invitations" has been merged
\i scenario/model/language_iso_full_text_search.sql

\echo all tests completed sucessfully.

\c - :USER_INITIAL

\echo ==========================================================
\echo  connect as :USER and drop schema vibetype_test
\echo ==========================================================

\i utility/test/cleanup.sql

DROP SCHEMA vibetype_test CASCADE;

\echo schema vibetype_test dropped.
\echo DONE!
