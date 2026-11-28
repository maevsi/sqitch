BEGIN;

DROP TRIGGER guest_count_update ON vibetype.guest;
DROP TRIGGER guest_count_delete ON vibetype.guest;
DROP TRIGGER guest_count_insert ON vibetype.guest;
DROP FUNCTION vibetype_private.trigger_guest_count_update();
DROP FUNCTION vibetype_private.trigger_guest_count_delete();
DROP FUNCTION vibetype_private.trigger_guest_count_insert();

DROP TRIGGER feedback_deadline_update ON vibetype.guest;
DROP TRIGGER feedback_deadline_insert ON vibetype.guest;
DROP FUNCTION vibetype_private.trigger_guest_feedback_deadline();

DROP TRIGGER update ON vibetype.guest;

DROP FUNCTION vibetype.trigger_guest_update();

DROP POLICY guest_delete ON vibetype.guest;
DROP POLICY guest_update ON vibetype.guest;
DROP POLICY guest_insert_join ON vibetype.guest;
DROP POLICY guest_insert ON vibetype.guest;
DROP POLICY guest_select ON vibetype.guest;

DROP FUNCTION vibetype_private.events_organized();
DROP FUNCTION vibetype_private.contacts_referring_invoker();
DROP FUNCTION vibetype_private.contacts_blocked();

COMMIT;
