BEGIN;

SELECT id,
       name,
       line_1,
       line_2,
       postal_code,
       city,
       region,
       country,
       created_at,
       created_by,
       updated_at,
       updated_by
FROM maevsi.address WHERE FALSE;

SELECT maevsi_test.index_existence(
  ARRAY ['idx_address_created_by', 'idx_address_updated_by']
);

ROLLBACK;
