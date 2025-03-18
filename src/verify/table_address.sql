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
FROM vibetype.address WHERE FALSE;

ROLLBACK;
