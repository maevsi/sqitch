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

\i function/function_test_utilities.sql
\i function/function_test_account.sql
\i function/function_test_contact.sql
\i function/function_test_event.sql
\i function/function_test_guest.sql
\i function/function_test_account_block.sql
\i function/function_test_friendship.sql
\i function/function_test_location.sql
\i function/function_test_index.sql

\i test/test_index.sql
\i test/test_audit_log.sql

\echo ==========================================================
\echo connect as user postgraphile and run tests
\echo ==========================================================

\c - postgraphile

\i test/test_account_registration.sql
\i test/test_authenticate.sql
\i test/test_account_block.sql
\i test/test_friendship.sql
\i test/test_location.sql
\i test/test_full_text_search.sql
\i test/test_guest.sql
-- TODO: remove comments when PR "feat(notification)!: inherit invitations" has been merged
--\i test/test_invitation.sql

\echo all tests completed sucessfully.

\echo ==========================================================
\echo  connect as :db_owner and drop schema vibetype_test
\echo ==========================================================

\c - :db_owner

\i function/drop_test_functions.sql

DROP SCHEMA vibetype_test CASCADE;

\echo schema vibetype_test dropped.
\echo DONE!
