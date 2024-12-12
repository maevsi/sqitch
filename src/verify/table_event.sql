BEGIN;

SELECT id,
       author_account_id,
       "description",
       "end",
       invitee_count_maximum,
       is_archived,
       is_in_person,
       is_remote,
       "location",
       "name",
       slug,
       "start",
       "url",
       visibility
FROM maevsi.event WHERE FALSE;

ROLLBACK;
