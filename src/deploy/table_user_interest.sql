-- Deploy maevsi:table_user_interest to pg

BEGIN;

CREATE TABLE maevsi.user_interest ( 
    user_id uuid NOT NULL REFERENCES maevsi.account(id) ON DELETE CASCADE, 
    category event_category NOT NULL, 
    PRIMARY KEY (user_id, category) 
);


COMMIT;
