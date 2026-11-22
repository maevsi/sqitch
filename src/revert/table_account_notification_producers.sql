BEGIN;

DROP TRIGGER notification_guest_feedback ON vibetype.guest;
DROP FUNCTION vibetype_private.trigger_account_notification_guest_feedback();

DROP TRIGGER notification_friendship_requested ON vibetype.friendship;
DROP FUNCTION vibetype_private.trigger_account_notification_friendship_requested();

DROP TRIGGER notification_friendship_accepted ON vibetype.friendship;
DROP FUNCTION vibetype_private.trigger_account_notification_friendship_accepted();

DROP TRIGGER notification_event_updated ON vibetype.event;
DROP FUNCTION vibetype_private.trigger_account_notification_event_updated();

DROP TRIGGER notification_event_invitation ON vibetype_private.outbox;
DROP FUNCTION vibetype_private.trigger_account_notification_event_invitation();

DROP TRIGGER notification_event_deleted ON vibetype.event;
DROP FUNCTION vibetype_private.trigger_account_notification_event_deleted();

COMMIT;
