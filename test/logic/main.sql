\cd :test_dir

\echo test_dir = :test_dir

\! pwd

\echo ==========================================================
\echo connected as :db_owner
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

\i scenario/database/audit_log.sql
\i scenario/database/index_missing.sql
\i scenario/database/index.sql

\echo ==========================================================
\echo connect as user postgraphile and run tests
\echo ==========================================================

\c - postgraphile

\i scenario/model/account_block.sql
\i scenario/model/account_registration.sql
\i scenario/model/authenticate.sql
\i scenario/model/friendship.sql
\i scenario/model/guest.sql
-- \i scenario/model/invite.sql -- TODO: remove comment when PR "feat(notification)!: inherit invitations" has been merged
\i scenario/model/language_iso_full_text_search.sql
\i scenario/location.sql -- TODO: refactor into account and event tests

\echo all tests completed sucessfully.

\echo ==========================================================
\echo  connect as :db_owner and drop schema vibetype_test
\echo ==========================================================

\c - :db_owner

\i utility/test/cleanup.sql

DROP SCHEMA vibetype_test CASCADE;

\echo schema vibetype_test dropped.
\echo DONE!
