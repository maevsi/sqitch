-- Deploy maevsi:enum_event_category to pg

BEGIN;

CREATE TYPE maevsi.event_category AS ENUM (
    'bar',
    'charities',
    'culture',
    'fashion',
    'festival',
    'film',
    'food_and_drinks',
    'kids_and_family',
    'lectures_and_books',
    'music', 
    'networking',
    'nightlife',
    'performing_arts',
    'seminars',
    'sports_and_active_life',
    'visual_arts' 
);

COMMIT;
