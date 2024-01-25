-- Deploy maevsi:table_event_category_mapping to pg

BEGIN;

CREATE TABLE maevsi.event_category_mapping ( 
    event_id uuid NOT NULL REFERENCES maevsi.event(id) ON DELETE CASCADE, 
    category maevsi.event_category NOT NULL, 
    PRIMARY KEY (event_id, category) 
);

COMMIT;
