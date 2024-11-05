-- Deploy maevsi:table_event_category to pg

BEGIN;

CREATE TABLE maevsi.event_category(
    category TEXT PRIMARY KEY
);

COMMENT ON TABLE maevsi.event_category IS 'Event categories.';
COMMENT ON COLUMN maevsi.event_category.category IS 'A category name.';

INSERT INTO maevsi.event_category(category)
VALUES ('bar'),
    ('charities'),
    ('culture'),
    ('fashion'),
    ('festival'),
    ('film'),
    ('food_and_drinks'),
    ('kids_and_family'),
    ('lectures_and_books'),
    ('music'),
    ('networking'),
    ('nightlife'),
    ('performing_arts'),
    ('seminars'),
    ('sports_and_active_life'),
    ('visual_arts');

END;
