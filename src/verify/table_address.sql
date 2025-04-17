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
FROM vibetype.address WHERE FALSE;

ROLLBACK;
