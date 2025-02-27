BEGIN;

SELECT id,

       city,
       country,
       line_1,
       line_2,
       location,
       name,
       postal_code,
       region,

       created_at,
       created_by,
       updated_at,
       updated_by
FROM maevsi.address WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['idx_address_location', 'idx_address_created_by', 'idx_address_updated_by']
);

ROLLBACK;
